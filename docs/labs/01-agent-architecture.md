# Lab 1 — Agent architecture and SDLC processes

**Domain 1: Prepare agent architecture and SDLC processes (15–20%)**

## What you are practising

- Configure agent planning to be distinct from agent execution
- Configure an agent to output a structured plan
- Validate agent plans
- Prevent agent action until the agent checked and approved
- Configure agent to produce inspectable artifacts within standard development tooling

## Setup

- A paid Copilot plan (the cloud agent needs one).
- `.github/agents/bicep-planner.agent.md` and `bicep-builder.agent.md` on `main`.

---

## Part A — Planning without the ability to act

1. Open an issue:

   > **Add optional diagnostic settings to the resource-groups pattern**
   >
   > Each entry in `parResourceGroups` should be able to opt into a diagnostic setting.
   > Use `@bicep-planner`.

2. Assign it to Copilot, or from the CLI:

   ```bash
   gh issue create --title "Add optional diagnostics to 0001-resource-groups" \
     --body "Use the bicep-planner agent. Each parResourceGroups entry should be able to opt into a diagnostic setting."
   ```

3. Watch what it produces.

### Verify

```bash
gh pr list --state all --limit 5
gh pr diff <n> --name-only
```

The diff must contain **exactly one file**, under `docs/plans/`. If it contains a `.bicep`
file, the boundary failed and that is worth investigating — read
`.github/agents/bicep-planner.agent.md` and check whether `tools:` still excludes `execute`.

Read the plan itself. A good one names files (`artifacts/types.bicep`, not "the types"),
includes the three-way version bump, and has a non-empty Risks section.

### Why this matters

`bicep-planner` has `tools: ["read", "search", "edit"]` and no `execute`. It is not *asked* to
plan rather than implement — it is *unable* to do anything else. That distinction is the
whole objective. An agent instructed to plan will start implementing the moment the plan feels
obvious; an agent without the tools cannot.

---

## Part B — Execution gated on an approved plan

1. Comment on the plan PR with a change, then merge it.

2. Open a second issue:

   > Implement the plan in `docs/plans/<slug>.md`. Use `@bicep-builder`.

3. Now do the negative case — open a third issue asking `bicep-builder` to implement something
   **with no plan file**:

   > Add a `parEnableSoftDelete` parameter to the locks module. Use `@bicep-builder`.

### Verify

The first should produce a code PR. The second should produce **no code changes** and a
statement that no plan exists.

If `bicep-builder` writes its own plan and then implements it, the guardrail is cosmetic —
it has collapsed the review step back into a single turn. Tighten the wording in
`bicep-builder.agent.md`, re-run, and note what changed. That iteration *is* Domain 4's
"revise instructions" objective; do it here and you have practised both.

---

## Part C — The agent cannot widen its own guardrails

1. Open an issue asking the agent to change its own configuration:

   > `bicep-planner` should be able to run `bicep build` to check its plans. Add `execute`
   > to its tools.

2. Let it produce a PR.

### Verify

```bash
gh pr view <n> --json files --jq '.files[].path'
gh pr view <n> --json reviewDecision,mergeable
```

The PR touches `.github/agents/bicep-planner.agent.md`, which `CODEOWNERS` owns. To see the
block rather than just the ownership, temporarily enable code-owner review:

```bash
gh api /repos/florezflow/agentic-ai-practice/rulesets/<id> --jq '.rules[] | select(.type=="pull_request")'
# set require_code_owner_review: true, re-PUT the ruleset, then re-check the PR
```

With it on, the PR needs your review — and since the agent is the author, you can give it.
That is exactly the case the setting is for.

> Leave `require_code_owner_review` **off** for your own PRs afterwards. You cannot approve a
> PR you authored, so leaving it on deadlocks a solo repo. Lab 6 covers this properly.

### Why this matters

The request in Part C is reasonable on its face. A planner that could verify its plans would
write better plans. The point is not that the change is wrong — it is that a capability
change must be a *decision*, made by a person, visible in a diff. `CODEOWNERS` on
`.github/agents/` is what makes it one.

---

## What the exam asks

- **Planning separated from execution** is a capability boundary, not an instruction. Questions
  frame it as "how do you *ensure* an agent produces a plan before acting" — the answer is
  restricting tools, not prompting harder.
- **Structured plan output**: a plan is only useful if it is inspectable in normal tooling. A
  committed markdown file that goes through PR review is; a plan in chat scrollback is not.
- **Preventing action until approved** has three separate mechanisms here, and questions
  distinguish them: branch rulesets (what can merge), environment protection rules (what can
  deploy), and `safe-outputs` (what an agentic workflow can write at all).
- **`CODEOWNERS` requests review; it does not block.** Blocking comes from
  "Require review from Code Owners" in a ruleset or branch protection. That two-part
  relationship is a common question.
- The cloud agent **cannot approve or merge its own PR**, and the person who triggered it
  cannot approve it either. Workflows on its PRs need an explicit "Approve and run workflows".
