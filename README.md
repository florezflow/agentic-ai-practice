# agentic-ai-practice

A hands-on lab environment for **GH-600 — GitHub Certified: Agentic AI Developer**.

The exam is not about writing AI code. It is about *operating, integrating, supervising and
governing AI agents inside a production-grade SDLC, with GitHub as the system of record and
control plane*. You cannot learn that from slides — you need a repository with real gates,
real review flows and real artefacts for agents to work against.

So this repo is a small but genuine **Azure Bicep Infrastructure-as-Code** project:
reusable modules, a pattern template that composes them, parameter files per environment,
and a CI/CD pipeline with branch protection, status checks and an approval-gated deployment.
Every GH-600 surface — custom agents, MCP, instructions, guardrails, agentic workflows — is
then layered on top of that, where it can actually be exercised and observed.

> **This repo is intentionally public.** GitHub Environment deployment protection rules
> (required reviewers, wait timers) are only available on Free/Pro/Team plans for public
> repositories. The approval-gate labs do not work in a private repo on these plans.

> **Nothing is ever created in Azure.** The deploy workflow runs `what-if` and `validate`
> only. The real deployment command exists but is disabled behind the `ALLOW_REAL_DEPLOY`
> repository variable.

## Exam domains → what exercises them here

| Domain | Weight | Where it lives |
|---|---|---|
| 1. Prepare agent architecture and SDLC processes | 15–20% | `AGENTS.md`, the plan-first protocol, `.github/agents/bicep-planner.agent.md`, PR-per-change flow |
| 2. Implement tool use and environment interaction | 20–25% | `tools:` in agent profiles, `.mcp.json`, repo MCP config, `.github/workflows/copilot-setup-steps.yml`, agent firewall |
| 3. Manage memory, state, and execution | 10–15% | `AGENTS.md` + path-specific instructions, `docs/plans/` artefacts, Copilot Memory |
| 4. Perform evaluation, error analysis, and tuning | 15–20% | PSRule → SARIF → code scanning, what-if artefacts, `whatif-analyzer` agent |
| 5. Orchestrate multi-agent coordination | 15–20% | GitHub Agentic Workflows (`gh aw`), planner → builder → reviewer handoff |
| 6. Implement guardrails and accountability | 10–15% | Rulesets, required reviewers on `prod`, `safe-outputs:`, least-privilege `permissions:`, `CODEOWNERS` |

Full mapping: [`docs/gh600-domain-map.md`](docs/gh600-domain-map.md).
Labs: [`docs/labs/`](docs/labs/).

## Layout

```
modules/                 Reusable Bicep building blocks (resource-group, locks)
patterns/                Compositions that consume modules and take array input
  0001-resource-groups/  Loops a list of resource groups + optional locks
.github/
  workflows/             CI gates, gated deploy, Copilot setup steps, agentic workflows
  agents/                Custom agent profiles (different tool postures)
  instructions/          Path-specific instructions (applyTo globs)
  copilot-instructions.md
.claude/                 Claude Code mirror of the same rules + skills
docs/                    Domain map, labs, plans written by agents
AGENTS.md                Canonical instructions for every AI tool
```

## Getting started

```bash
gh repo clone mflorez-bag/agentic-ai-practice
cd agentic-ai-practice

# Validate everything locally, exactly as CI does
az bicep install
az bicep build --file patterns/0001-resource-groups/resource-groups.bicep
az bicep build-params --file patterns/0001-resource-groups/configurations/test/rg_0001-resource-groups_test.bicepparam
```

Then work through `docs/labs/01-agent-architecture.md` onwards.
