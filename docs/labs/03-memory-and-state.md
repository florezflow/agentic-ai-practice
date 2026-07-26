# Lab 3 — Memory, state and execution

**Domain 3: Manage memory, state, and execution (10–15%)**

## What you are practising

- Choose between short-term, long-term, and external memory
- Scope agent memory to task-relevant information
- Define memory expiration, pruning, and reset rules
- Capture task progress and decisions as durable artifacts
- Resume agent work without repeating steps or diverging from prior decisions
- Detect and correct drift during extended agent execution
- Share agent state; prevent conflicting and stale context

---

## The three kinds of memory in this repo

| Kind | Where | Lifetime | Scope |
|---|---|---|---|
| Short-term | the session's own context | the session | that session |
| Long-term | `AGENTS.md`, `.github/instructions/` | until edited | every agent, every session |
| External / durable | `docs/plans/`, what-if artefacts, PR history | until deleted | anyone, including humans |
| Managed | Copilot Memory | **28 days unused** | repository facts, or one user's preferences |

Most of this lab is about the third row, because it is the one you control completely.

---

## Part A — Scoping context with `applyTo`

The four files in `.github/instructions/` carry `applyTo:` globs. They are loaded only when the
agent touches a matching file.

1. Ask an agent to edit `patterns/0001-resource-groups/resource-groups.bicep`.
2. Ask it, in a separate session, to edit `.github/workflows/deploy.yml`.
3. In each case ask: *"What rules are you working under? Quote them."*

### Verify

The first session should quote `bicep-standards.instructions.md` — `//MARK:` order, `par*`
naming, safe access. The second should quote `workflows.instructions.md` — least privilege,
pinning, "checks must be able to fail".

Neither should quote the other. That is the objective "scope agent memory to task-relevant
information", made mechanical: an agent editing a workflow does not need to carry Bicep naming
rules, and every irrelevant rule in context is one more thing competing for attention.

### The uneven-support trap

Now ask the **same question in chat on github.com**, with no file open.

It quotes `.github/copilot-instructions.md` only. It does **not** read `AGENTS.md`, and it does
**not** read path-specific instructions. That is why `copilot-instructions.md` in this repo
repeats the non-negotiables instead of only linking to the canon — a rule that lives only in a
file a surface cannot read is a rule that surface does not have.

---

## Part B — Interruption and resume

This is the core exercise. Do it properly.

1. Give `bicep-planner` a task large enough to need several steps — for example, adding a
   second pattern that creates resource groups *and* role assignments.
2. Let it write `docs/plans/<slug>.md`. Merge that PR.
3. **Stop.** Close the session entirely.
4. In a completely new session, with no history, say only:

   > Continue the work described in `docs/plans/<slug>.md`.

### Verify

The new session should pick up at the first unfinished step, not re-analyse the problem. Check
specifically whether it reaches the **same decisions** — same file layout, same type names,
same version-bump plan.

Then run the counterfactual: start a third fresh session and give it the original task with
**no plan file**. Compare its approach to the plan.

The difference between those two runs is the entire value of durable state. Without the
artefact, a resumed session does not continue the work — it starts similar work, and the two
halves may not fit together.

---

## Part C — Drift detection

1. Take an approved plan and ask `bicep-builder` to implement it.
2. Before reviewing the code, re-read the plan.
3. Diff intent against reality:

   ```bash
   gh pr diff <n> --name-only
   ```

   Compare to the plan's `## Files` section.

### Verify

Files in the diff that are not in the plan are drift. Files in the plan that are not in the
diff are incomplete work. Either way the plan should have been updated and was not — that is
what the PR template's *"The plan artefact matches what actually landed"* checkbox is asking.

Drift is not automatically wrong. Implementation reveals things planning could not. The failure
is **silent** drift: updating the plan costs one commit, and not updating it destroys the only
property the artefact had.

---

## Part D — Expiry and staleness

Copilot Memory deletes any stored fact or preference **unused for 28 days**. The timer resets
each time a fact is validated and used.

There is no equivalent for your own durable state — `docs/plans/` never expires. Manage it
explicitly:

1. Find plans whose `Status` line is stale:

   ```bash
   grep -A1 '^## Status' docs/plans/*.md
   ```

2. For each, set `landed in #<pr>` or `abandoned (<reason>)`.

Keep abandoned plans. Knowing what was tried and rejected — with the reason — is worth more
than a tidy directory, and it stops the next agent proposing the same rejected approach.

### Conflicting context

Deliberately create a contradiction: add a rule to `.github/copilot-instructions.md` that
disagrees with `AGENTS.md`, for example naming parameters `p*` instead of `par*`. Run a task.
Observe which wins, and whether the agent notices the conflict at all.

Then remove it, and note why `CLAUDE.md` in this repo is a single `@AGENTS.md` line rather than
a copy. Two files saying the same thing is one file eventually saying something different.

---

## What the exam asks

- **Copilot Memory: 28 days** for unused facts and preferences; the timer resets on use.
  Repository facts are usable only in operations on **that** repository. User preferences are
  available only in **that** user's later interactions.
- **Repository facts are stored with citations** to the supporting code, and validated against
  the current branch before use. Only confirmed facts get applied.
- **Instruction file support is uneven** and is a favourite question. `copilot-instructions.md`
  is read by every surface; `AGENTS.md` and `*.instructions.md` are **not** read by chat on
  github.com.
- **`AGENTS.md` nearest-wins**: multiple `AGENTS.md` files can exist anywhere in the tree, and
  the nearest one to the file being worked on takes precedence.
- **`@path` includes** work inside `copilot-instructions.md`, `AGENTS.md` and `CLAUDE.md` —
  and are **not** expanded in `*.instructions.md` or `GEMINI.md`.
- **Durable artefacts beat conversation.** Anything that must survive a session ends up in the
  repository, not in scrollback.
