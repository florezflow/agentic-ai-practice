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

### Known state

- The agentic workflows are authored and compiled but **not yet runnable**: a personal
  repository needs a paid Copilot plan and a `COPILOT_GITHUB_TOKEN` secret. Until it is set,
  the `activation` job fails fast and the `agent` and `safe_outputs` jobs skip.
- Azure OIDC is not configured. The `whatif` job self-skips with an explanatory summary, and
  the approval gate still exercises.

### Repository configuration (not in git)

- Environments: `test`, `prod` (required reviewer + 1 minute wait timer), and ungated
  `test-preview` / `prod-preview` used by the what-if job.
- Ruleset `main-protection` on the default branch: pull request required, conversation
  resolution required, force-push and deletion blocked, `lint` + `psrule` + `version-sync`
  required to pass.
- Repository variable `ALLOW_REAL_DEPLOY = false`.
