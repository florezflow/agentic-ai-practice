# GH-600 domain map

Every exam objective, and the thing in this repository that exercises it.

**Exam:** GH-600, GitHub Certified: Agentic AI Developer. 120 minutes, ~40–60 questions,
700 to pass. Six domains.

Objective bullets below are from the
[official study guide](https://learn.microsoft.com/credentials/certifications/resources/study-guides/gh-600).

---

## Domain 1 — Prepare agent architecture and SDLC processes (15–20%)

| Objective | Where it lives |
|---|---|
| Identify steps for agents to perform | `.github/agents/` — four agents, four scopes, none of them "do everything" |
| Identify and mitigate common anti-patterns | `AGENTS.md` "flag rather than do"; `bicep-builder`'s refusal to weaken a check |
| Define inputs, outputs, success criteria | Each agent profile's output format; `AGENTS.md` "Definition of done" |
| Configure planning distinct from execution | `bicep-planner` has no `execute`; `bicep-builder` refuses to start without a plan |
| Configure an agent to output a structured plan | The plan template in `bicep-planner.agent.md` and `docs-and-plans.instructions.md` |
| Validate agent plans | Plans are committed and reviewed before implementation |
| Prevent agent action until checked and approved | `main-protection` ruleset; `prod` required reviewer; `safe-outputs` |
| Plan and implement degree of autonomy | The tool-posture table below |
| Produce inspectable artefacts in standard tooling | Plan files, what-if artefacts, SARIF in the Security tab, PR comments |
| Configure human intervention without slowing delivery | Gate on `prod` only; `test` deploys ungated; PR checks run in ~1 minute |

**Lab:** [`labs/01-agent-architecture.md`](labs/01-agent-architecture.md)

---

## Domain 2 — Implement tool use and environment interaction (20–25%)

| Objective | Where it lives |
|---|---|
| Identify required tools / configure agent tools | `tools:` in each `.github/agents/*.agent.md` |
| Configure agent tool permissions | The four postures below |
| Add an MCP server as a tool | `docs-researcher.agent.md` `mcp-servers:` block; `.mcp.json` for Claude Code |
| Configure a GitHub remote MCP server | `.mcp.json` `github` entry (`https://api.githubcopilot.com/mcp`) |
| Configure MCP registries / allow lists | `docs/mcp-and-firewall.md` — repo settings vs. in-profile, and the firewall's limits |
| Evaluate the execution context for an agent | `copilot-setup-steps.yml`, which verifies the agent can reproduce CI |
| Scope an agent to a repository | Built-in `github` MCP server is scoped to the source repo |
| Invoke an agent in a CI workflow | The three agentic workflows |
| Branch-based scope / autonomous branches and PRs | Cloud agent's `copilot/*` branches; `safe-outputs: create-pull-request` |
| Handle environment-specific constraints | Pinned Bicep version shared by CI and setup steps |
| Error handling, retries, rollbacks, escalation | `pr-validate.yml` produce-then-enforce; what-if before apply; PR revert as rollback |
| Traceability and accountability | What-if provenance sidecar; signed agent commits; `CODEOWNERS` |

**The four tool postures** — the same task behaves differently under each, which is the point:

| Agent | `tools:` | Cannot |
|---|---|---|
| `bicep-planner` | `read`, `search`, `edit` | run anything |
| `bicep-builder` | full | (bounded by instructions, not capability) |
| `whatif-analyzer` | `read`, `search` | change anything |
| `docs-researcher` | `microsoft-learn/*` | see the repository at all |

**Lab:** [`labs/02-tools-and-mcp.md`](labs/02-tools-and-mcp.md)

---

## Domain 3 — Manage memory, state, and execution (10–15%)

| Objective | Where it lives |
|---|---|
| Choose short-term, long-term, external memory | Session context vs. `AGENTS.md` vs. `docs/plans/` |
| Scope memory to task-relevant information | `applyTo:` globs on `.github/instructions/*.instructions.md` |
| Memory expiration, pruning, reset | Copilot Memory deletes unused entries after **28 days**; plan `Status` lines |
| Capture progress and decisions as durable artefacts | `docs/plans/` — committed, updated, never deleted |
| Resume without repeating steps or diverging | The plan file is what a resumed session reads instead of re-deriving |
| Detect and correct drift during long execution | Plan-vs-diff comparison in the PR template |
| Share state across tools and environments | One `AGENTS.md`, read by Copilot and Claude Code; `CLAUDE.md` is a pointer |
| Prevent conflicting and stale context | Single canon, no duplicated rules between `CLAUDE.md` and `AGENTS.md` |

**Lab:** [`labs/03-memory-and-state.md`](labs/03-memory-and-state.md)

---

## Domain 4 — Perform evaluation, error analysis, and tuning (15–20%)

| Objective | Where it lives |
|---|---|
| Specify expected outcomes and constraints | `AGENTS.md` "Definition of done" |
| Qualitative and quantitative evaluation signals | PSRule findings (quantitative); PR review comments (qualitative) |
| Align evaluation criteria with development intent | `.ps-rule/` for repo-specific rules; instruction files as the review authority |
| **Generate evaluation signals with automated scanning** | `psrule` job → SARIF → code scanning Security tab |
| Identify failures via logs, plans, traces, artefacts | `gh run view --log`, what-if artefacts, `gh aw logs`, `gh aw audit` |
| Classify root causes | `whatif-analyzer`'s four-bucket classification |
| Revise instructions, workflows, constraints | The tuning loop in Lab 4 |
| Refine memory usage / tool access | Narrowing `toolsets` rather than widening `permissions` |

**Lab:** [`labs/04-evaluation-and-tuning.md`](labs/04-evaluation-and-tuning.md)

---

## Domain 5 — Orchestrate multi-agent coordination (15–20%)

| Objective | Where it lives |
|---|---|
| Apply an orchestration pattern | planner → builder → reviewer handoff, mediated by the plan file |
| Configure isolation for parallel execution | Separate branches; `safe-outputs: create-pull-request` instead of push |
| Detect and resolve agent conflicts | Two agents on overlapping files, in Lab 5 |
| Produce artefacts suitable for review and audit | Plan files, agentic-workflow run logs, `gh aw audit` |
| Document decisions, handoffs, outcomes | Plan `Status` line; PR "Agent involvement" section |
| Post-hoc analysis of multi-agent behaviour | `gh aw logs`, `gh aw audit <run-id>` |
| Identify failed, partial, stalled executions | `daily-iac-report` surfaces failing runs and stalled deployments |
| Multi-agent recovery: rollback, human-in-the-loop | Revert PR; the `prod` approval gate |
| Add / update / retire agents without disruption | Agent profiles are files — add, edit or delete one in a PR |

**Lab:** [`labs/05-multi-agent.md`](labs/05-multi-agent.md)

---

## Domain 6 — Implement guardrails and accountability (10–15%)

| Objective | Where it lives |
|---|---|
| Classify actions by operational, security, compliance risk | `AGENTS.md` "flag rather than do"; PR template "Blast radius" |
| Assign autonomy levels | `test` ungated, `prod` gated; `ALLOW_REAL_DEPLOY` off |
| Identify actions requiring human judgement | Environment approvals; `CODEOWNERS` on the agent control surface |
| Block actions violating policy | Ruleset; `safe-outputs` allow-list; `.claude/settings.json` deny list |
| Scope permissions to least privilege | Job-level `permissions:`; narrowed toolsets; four agent tool postures |
| Require authorization for irreversible changes | `prod` reviewer + wait timer; `ALLOW_REAL_DEPLOY`; what-if before apply |
| Preserve velocity by minimising low-value approvals | Only `prod` has a reviewer; checks are fast; `test` needs no approval |

**Lab:** [`labs/06-guardrails.md`](labs/06-guardrails.md)

---

## Facts worth memorising

Details that this repo demonstrates and the exam tends to probe:

- **Environment protection rules** (required reviewers, wait timers, custom rules) work on
  **public** repos on every plan; on **private** repos they need **Enterprise**. This repo is
  public for exactly that reason.
- **Environment variables and environment gates are coupled.** A job reading `vars.X` must
  declare `environment:` and inherits its gate — hence the ungated `-preview` environments.
- **The agent firewall covers only Bash-tool processes.** Not MCP servers, not
  `copilot-setup-steps.yml`.
- **`copilot-setup-steps.yml`**: the job must be named `copilot-setup-steps`; only `steps`,
  `permissions`, `runs-on`, `services`, `snapshot`, `timeout-minutes` (≤59) are honoured; must
  be on the default branch. Its `permissions:` do **not** affect the agent's own token.
- **Instruction support is uneven.** `.github/copilot-instructions.md` is read by every
  surface; `AGENTS.md` and path-specific `*.instructions.md` are **not** read by chat on
  github.com.
- **Copilot Memory** deletes unused facts and preferences after **28 days**; the timer resets
  on use. Repository facts never cross repositories; user preferences never cross users.
- **The cloud agent cannot** merge a PR, approve a PR, mark a draft ready, or run Git commands
  directly. Workflows on its PRs need a human "Approve and run workflows" click. Its commits
  are signed and co-authored by the requester, who cannot approve them.
- **Agentic workflows are read-only by default**; writes exist only through `safe-outputs:`.
  On a personal repo they need `COPILOT_GITHUB_TOKEN`; on an org repo,
  `copilot-requests: write` plus an org policy.
- **Agent profile `tools:`** takes aliases (`read`, `edit`, `search`, `execute`, `web`,
  `agent`, `todo`), `"mcp-server/tool"`, `"mcp-server/*"`, `["*"]` for everything, or `[]` for
  nothing. Omitting the property means everything.
