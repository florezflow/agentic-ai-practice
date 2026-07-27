# REPO-CHANGELOG

Repository-level history, in calendar versions. Component versions live in each component's
own `CHANGELOG.md`; this file records what changed about the repository as a whole.

Format: `## YYYY.MM.DD[-N] - DD.MM.YYYY`, newest first. The `-N` sequence number distinguishes
multiple entries on the same day.

## 2026.07.26 - 26.07.2026

- Wiped the unused Python/Azure-AI scaffold and laid the Bicep IaC skeleton:
  `bicepconfig.json` with the full linter rule set, `.editorconfig`, `.gitignore`, MIT licence.
- Added `modules/resources/resource-group` and `modules/resources/locks` (both v1.0.0), and
  the `patterns/0001-resource-groups` pattern (v1.0.0) that composes them from a single array
  parameter.
- Added the three required status checks — `lint`, `psrule`, `version-sync` — plus
  `ps-rule.yaml`, `CODEOWNERS` and a pull request template that asks about agent involvement
  and blast radius.
- Added the manual, approval-gated `deploy.yml`: an ungated `whatif` job that produces a
  what-if artefact with a provenance sidecar, and an `apply` job bound to the `test`/`prod`
  environments. `prod` carries a required reviewer and a wait timer.
- Added the instruction layer: `AGENTS.md` as the single canon, `CLAUDE.md` pointing at it,
  `.github/copilot-instructions.md` for surfaces that read nothing else, four path-specific
  `*.instructions.md` files, `.mcp.json`, and Claude Code skills for validate / bump-version /
  new-pattern.
- Added four custom agent profiles with deliberately different tool postures —
  `bicep-planner` (no `execute`), `bicep-builder` (full, but refuses to start without a plan),
  `whatif-analyzer` (read-only), `docs-researcher` (one MCP server, no filesystem) — plus
  `copilot-setup-steps.yml`, which installs the pinned Bicep CLI and PSRule and then runs the
  repo's own checks to prove the agent environment can reproduce CI.
- Added three GitHub Agentic Workflows: `bicep-pr-reviewer` (`add-comment`),
  `daily-iac-report` (`create-issue`) and `version-sync-fixer` (`create-pull-request`).
  Compiled with zero warnings by narrowing `toolsets` rather than widening `permissions`.
- Added `docs/gh600-domain-map.md` and six labs, one per exam domain, plus
  `docs/mcp-and-firewall.md` and `docs/agentic-workflows.md`.

## 2026.07.27 - 27.07.2026

- Configured Azure OIDC end to end. Entra app registration `mfl-deploy-gh-action`
  (client `70ac3c10-fc4a-4a04-911e-daa540a85e8c`) in tenant
  `54dd9757-341b-4fa9-8016-1f47cd42f780`, with one federated credential per environment and
  Contributor on the sponsorship subscription `f5c4a850-…`. `AZURE_CLIENT_ID`,
  `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` and `AZURE_LOCATION` set as variables on all four
  environments. Verified: `what-if` against `test` returns 3 resource groups to create.
- Set `COPILOT_GITHUB_TOKEN`, so the agentic workflows can run.
- Added AI spending caps as repository variables — 30 credits per run, 100 per day, 20 turns,
  15 minutes. The built-in fallback was 5,000 credits/day, well above a monthly allowance, so
  the brake would never have engaged.
- Changed `daily-iac-report` from `schedule: daily` to `workflow_dispatch`. It compiled to a
  real cron and would have spent credits nightly, unattended, from the moment the token
  existed.
- Added `docs/reference-links.md` — every official documentation page the repo depends on, in
  one place — and short explanatory comments with links into it across the workflows, agent
  profiles, Bicep templates and parameter files.
- Pinned `GH_AW_DEFAULT_MODEL_COPILOT = gpt-4.1`. The `gh aw` default `claude-sonnet-4.6` is
  not available on this Copilot tier and every run failed with "model not supported".
  `claude-sonnet-5` and `gpt-5.5` are both *listed* as available and both fail identically with
  HTTP 403 mid-run, so this org-assigned seat can use base models through the CLI but not
  premium ones. `gpt-4.1` completes, at 3.25 AI credits for a 21-file review.
- Tuned `bicep-pr-reviewer` to always use `add-comment`, never `noop`. Its first successful run
  produced a correct review and returned it as `noop`, so nothing was posted — the previous
  wording said "say so in one line and stop", and the agent read "stop" as "stay silent".

### Known state

- Everything is now wired: gates, approval gate, agentic workflows and real Azure what-if.
- **Nothing is ever created in Azure.** `ALLOW_REAL_DEPLOY` is `false`, so `apply` runs
  `az deployment sub validate` and stops there.
- `daily-iac-report` is manual-only. Switch it back to `schedule: daily` once you know what a
  run costs against your credit allowance.

### Repository configuration (not in git)

- Environments: `test`, `prod` (required reviewer + 1 minute wait timer), and ungated
  `test-preview` / `prod-preview` used by the what-if job. All four carry the four
  `AZURE_*` variables.
- Ruleset `main-protection` on the default branch: pull request required, conversation
  resolution required, force-push and deletion blocked, `lint` + `psrule` + `version-sync`
  required to pass. `require_code_owner_review` is deliberately **off** — a solo maintainer
  cannot approve their own pull request.
- Repository secret: `COPILOT_GITHUB_TOKEN`.
- Repository variables: `ALLOW_REAL_DEPLOY = false`, `GH_AW_DEFAULT_MAX_AI_CREDITS = 30`,
  `GH_AW_DEFAULT_MAX_DAILY_AI_CREDITS = 100`, `GH_AW_DEFAULT_DETECTION_MAX_AI_CREDITS = 5`,
  `GH_AW_DEFAULT_MAX_TURNS = 20`, `GH_AW_DEFAULT_TIMEOUT_MINUTES = 15`.
- Azure: Entra app `mfl-deploy-gh-action`, four federated credentials
  (`repo:mflorez-bag/agentic-ai-practice:environment:<env>`), Contributor on the sponsorship
  subscription.
