# Lab 5 — Multi-agent coordination

**Domain 5: Orchestrate multi-agent coordination (15–20%)**

## What you are practising

- Apply an orchestration pattern to coordinate multiple agents
- Configure agent isolation for parallel execution
- Detect and resolve agent conflicts: overlapping code changes, duplicated effort,
  contradictory outputs
- Produce artifacts suitable for review and audit; document decisions, handoffs and outcomes
- Perform post-hoc analysis of multi-agent behaviour
- Identify failed, partial, or stalled executions; implement recovery patterns
- Add, update, replace and retire agents without disrupting active workflows

---

## The orchestration pattern in this repo

```
   bicep-planner  ──writes──▶  docs/plans/<slug>.md  ──reads──▶  bicep-builder
        │                            ▲                                │
        │                            │                                ▼
   docs-researcher ─────facts────────┘                       pull request
                                                                     │
                                                    bicep-pr-reviewer │ (agentic workflow)
                                                                     ▼
                                                          whatif-analyzer ──▶ human
```

The handoff medium is a **file**, not a conversation. That is deliberate and it is the whole
lesson: agents that hand off through a shared artefact can run at different times, in different
sessions, on different tools, and a human can inspect the seam. Agents that hand off through
context cannot do any of those.

---

## Part A — A real handoff

1. **`docs-researcher`**: *"What is the current stable API version for
   `Microsoft.Authorization/locks`, and what changed since 2020-05-01?"*

   It cannot see the repo. It answers from documentation, with a citation.

2. **`bicep-planner`**: *"Using that API version, plan an upgrade to
   `modules/resources/locks`."*

   It can see the repo but cannot verify anything externally. Give it the researcher's answer.

3. **`bicep-builder`**: *"Implement `docs/plans/<slug>.md`."*

4. **`bicep-pr-reviewer`** fires automatically on the PR.

### Verify

Read the plan file. It should contain the API version fact **and where it came from**. If it
does not, the handoff lost the provenance — the builder is now acting on a claim with no
traceable source, and nobody downstream can tell whether it was checked or invented.

That is the failure mode to internalise: information survives a handoff, confidence does not,
unless you write down where it came from.

---

## Part B — Conflict between parallel agents

Deliberately create the overlap.

1. Open two issues at the same time, both touching
   `patterns/0001-resource-groups/artifacts/types.bicep`:
   - *"Add an `enableDiagnostics` flag to `resourceGroupConfig`."*
   - *"Add a `costCenterOverride` field to `resourceGroupConfig`."*

2. Assign both to Copilot.

### Verify

```bash
gh pr list --json number,headRefName,mergeable,files
```

Both land on separate `copilot/*` branches, so neither blocks the other while it works — that
is the isolation. The conflict surfaces at merge: the second PR goes `MERGEABLE → CONFLICTING`
once the first lands.

Resolve it, then note which mechanism actually did the work. It was not agent coordination —
neither agent knew the other existed. It was **branch isolation plus a merge gate**, which is
the same mechanism that handles two humans. Multi-agent safety is mostly the SDLC you already
had, applied without exceptions.

### The harder conflict

Contradictory *outputs* do not surface at merge. Ask two agents the same question with
different tool postures — `bicep-planner` (sees the repo) and `docs-researcher` (sees the
docs) — about whether an API version is current. They can disagree, both plausibly, and
nothing mechanical catches it.

The only defence is that each states its evidence, so a human can see which one is answering
from something and which from nothing.

---

## Part C — Post-hoc analysis

```bash
gh aw logs bicep-pr-reviewer          # download and analyse run logs
gh aw audit <run-id>                  # detailed trace of one run
gh run view <run-id> --log            # raw Actions log
```

For the cloud agent, open the session log linked from its commit messages.

### Verify

For a single task, reconstruct: what the agent was asked, what tools it called, what it
produced, what it could not do. If you cannot reconstruct it, the audit trail has a hole —
find which artefact is missing and add it.

---

## Part D — Stalled and partial executions

`daily-iac-report` exists to surface exactly this. Force each case:

| Case | How to create it |
|---|---|
| **Failed** | Push a `.bicep` with a syntax error |
| **Partial** | Ask an agent for a change needing a version bump; stop it after the code edit |
| **Stalled** | Dispatch `deploy.yml` at `prod` and do not approve |

Then run the reporter:

```bash
gh aw run daily-iac-report
```

### Verify

The issue names all three. A stalled deployment awaiting approval is the one most often missed
by monitoring — it is not failing, it is not running, and nothing times out. Check that the
report says how long it has been waiting.

Recovery patterns to practise on the partial case:

- **Rollback:** `gh pr revert` or a revert commit. Every agent change here arrives as a PR, so
  every agent change is revertible by construction.
- **Human-in-the-loop:** the `prod` approval gate.
- **Retry with narrower scope:** re-run only the failed step, not the whole task.

---

## Part E — Agent lifecycle

Each of these is a PR against `.github/agents/`, which is what "without disrupting active
workflows" means in practice.

1. **Add** a fifth agent — a `changelog-writer` with `tools: ["read", "search", "edit"]`.
2. **Update** an existing one: narrow `whatif-analyzer` to `tools: ["read"]` and see what
   breaks.
3. **Retire** one: delete the profile. Confirm the git history and any plan files that
   reference it survive.

### Verify

Retiring an agent must not orphan its artefacts. `docs/plans/` files written by a deleted agent
stay valid and readable — that is the difference between deleting an agent and deleting its
work. If retiring an agent loses history, the artefacts were in the wrong place.

---

## What the exam asks

- **Isolation for parallel execution** means separate branches and separate working copies.
  For agentic workflows it also means `safe-outputs: create-pull-request` instead of push
  access — the agent never has a writable checkout of the base branch.
- **Conflict types are distinct**: overlapping code changes (caught at merge), duplicated
  effort (caught by review), contradictory outputs (caught by nothing — only by evidence).
  Questions test whether you know which is which.
- **Artefacts suitable for audit** must survive the session. Committed plan files, run logs and
  PR history qualify; chat scrollback does not.
- **Recovery patterns**: rollback, human-in-the-loop, retry with reduced scope. Know which
  applies to a failed, a partial, and a stalled execution.
- **Lifecycle**: agents are configuration files. Adding, changing and retiring them is a pull
  request, reviewed like any other — which is why `CODEOWNERS` covers the directory.
- A **stalled** execution is the hard one to detect precisely because nothing failed.
