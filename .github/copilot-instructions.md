# Copilot instructions

Repository-wide instructions. This is the only instruction type every Copilot surface reads —
`AGENTS.md` and `.github/instructions/*.instructions.md` are **not** read by chat on
github.com. So this file repeats the rules that must never be missed, rather than only
pointing elsewhere.

The full canon is [`AGENTS.md`](../AGENTS.md). Read it when you have the ability to.

## What this repo is

Azure Bicep infrastructure-as-code, used as a practice environment for supervising AI agents
in a gated SDLC.

- **Nothing is ever created in Azure.** CI runs `what-if` and `validate` only.
- **Do not work around a failing check.** Never disable a rule, add a suppression, or loosen a
  permission to make something pass. Report the failure.

## Non-negotiables

- **English** for identifiers, descriptions, documentation and commit messages.
- **Plan before implementing.** Anything larger than a one-line edit gets a plan file in
  `docs/plans/` first, agreed before code is written.
- **Bicep section order:** `METADATA → TYPES → DEPLOYMENT SCOPE → PARAMETERS → VARIABLES →
  RESOURCES → OUTPUTS`, each introduced by a `//MARK: - <SECTION>` comment.
- **Naming:** `par*` parameters, `var*` variables, `res*` resources, `mod*` modules, outputs
  unprefixed camelCase, files and folders kebab-case.
- **Safe access:** `x.?prop ?? default`. Never `x.prop!`.
- **Versions:** `metadata.json`, `metadata version = 'X.Y.Z'` and the `## X.Y.Z` heading in
  `CHANGELOG.md` must agree. The `version-sync` check enforces it.
- Modules do one thing and take plain parameters. Patterns own naming, tags, scope and
  deployment flags.

## Verify before proposing

```bash
bicep build <template>.bicep --stdout > /dev/null
bicep build-params <file>.bicepparam --stdout > /dev/null
bash .github/scripts/validate-version-sync.sh
```

Never report a check as passing that you did not run.

## Flag, do not do silently

Changes to `.github/workflows/`, `.github/agents/`, `.github/instructions/`, `AGENTS.md`,
`CODEOWNERS`, `bicepconfig.json`, `ps-rule.yaml` — or any `deploymentFlags` flip, entry removal
from `parResourceGroups`, or widened workflow `permissions:` — must be called out explicitly in
your response and in the pull request description.
