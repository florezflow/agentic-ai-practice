# AGENTS.md

Canonical instructions for every AI tool working in this repository — GitHub Copilot (cloud
agent, code review, CLI), Claude Code, and anything else that reads `AGENTS.md`. `CLAUDE.md`
is a pointer to this file, so there is one canon and no drift between tools.

If you are a human: this file is also the fastest description of how the repo works. For the
official documentation behind any of it, see [`docs/reference-links.md`](docs/reference-links.md).

---

## What this repository is

An Azure Bicep infrastructure-as-code repo that exists to be a **realistic environment for
practising agent supervision** (GH-600). The infrastructure is deliberately small; the
controls around it are not.

Two properties follow from that, and they override the usual instincts:

1. **Nothing is ever created in Azure.** CI runs `what-if` and `validate` only. If a task
   seems to require a real deployment, it does not — say so instead of finding a way.
2. **The gates are the product.** Do not work around a failing check, disable a rule, add a
   suppression, or loosen a permission to make something pass. A red check is information.
   Report it; do not route around it.

---

## Layout

```
modules/<category>/<module>/         main.bicep + metadata.json + CHANGELOG.md
patterns/NNNN-<name>/                <name>.bicep + metadata.json + CHANGELOG.md
                                     artifacts/types.bicep
                                     configurations/{test,prod}/*.bicepparam
                                     docs/deployment-notes.md
.github/workflows/                   pr-validate.yml, deploy.yml, copilot-setup-steps.yml
.github/agents/                      custom agent profiles
.github/instructions/                path-specific instructions (applyTo globs)
docs/plans/                          plan artefacts — see "Plan first" below
docs/labs/                           the GH-600 exercises
```

A **module** does one thing and takes plain parameters. It never composes names, never invents
conventions, never reaches for `resourceGroup().tags`. A **pattern** composes modules and owns
everything the modules refuse to: naming, tag inheritance, scope resolution, deployment flags.

When you are unsure where logic belongs, ask: *would a different pattern want this to be
different?* If yes, it belongs in the pattern.

---

## Plan first

For anything beyond a one-line edit, **write the plan before you touch code**:

1. Write `docs/plans/<short-slug>.md` containing: the goal, the files you intend to change,
   the approach, and what could go wrong.
2. Stop. Wait for a human to agree with the plan.
3. Implement it. If implementation reveals the plan was wrong, update the plan file and say
   so — do not silently diverge.

This is not ceremony. It exists because:

- **Planning and execution are separate concerns.** A plan can be reviewed in a minute; a
  400-line diff cannot.
- **The plan is durable state.** If a session is interrupted, the next one reads the plan
  instead of re-deriving it — and reaches the same conclusions rather than new ones.
- **A plan that does not match the diff is a signal.** The pull request template asks about
  this explicitly.

Plan files are committed. They are the record of what was decided and why.

---

## Before you propose anything

Run these. They are the same checks CI runs, so there is no excuse for a red PR:

```bash
# every template
bicep build <path/to/template.bicep> --stdout > /dev/null

# every parameter file
bicep build-params <path/to/file.bicepparam> --stdout > /dev/null

# version consistency across all components
bash .github/scripts/validate-version-sync.sh
```

If you cannot run a command, say that you could not run it. Never report a check as passing
that you did not execute.

---

## Bicep conventions

**Section order in every template — mandatory, and checked in review:**

```bicep
//MARK: - METADATA
//MARK: - TYPES            // imports, patterns only
//MARK: - DEPLOYMENT SCOPE
//MARK: - PARAMETERS       // @secure() parameters first
//MARK: - VARIABLES        // optional
//MARK: - RESOURCES
//MARK: - OUTPUTS          // optional
```

**Naming:**

| Kind | Convention | Example |
|---|---|---|
| Parameter | `par` + PascalCase | `parResourceGroupName` |
| Variable | `var` + PascalCase | `varResourceGroups` |
| Resource | `res` + PascalCase | `resResourceGroup` |
| Module | `mod` + PascalCase | `modLocks` |
| Output | no prefix, camelCase | `resourceGroupName` |
| File / folder | kebab-case | `resource-group/main.bicep` |

**Rules that matter more than they look:**

- **Safe access everywhere.** `rg.?location ?? parBaseConfig.defaultLocation`, never
  `rg.location!`. The `!` operator moves a failure from compile time to deploy time.
- **Resolve optionals once.** Patterns compute a `var` array where every optional property is
  already defaulted, then loop over that. Do not scatter `??` through the module calls.
- **Guard every module loop with a deployment flag**, e.g.
  `if (parBaseConfig.deploymentFlags.locks && rg.enableLock)`.
- **`dependsOn` only when there is no implicit dependency**, but do not remove one that is
  load-bearing. A `scope:` built from a string creates no dependency — the lock module needs
  its `dependsOn` and the comment above it says so.
- **Types live in `artifacts/types.bicep`** and are imported. Never redefine a type inline.
- **API versions**: recent stable, no previews unless there is no alternative. The linter
  warns beyond 730 days.
- **Every parameter gets an `@description()`** with the shields.io badge prefix used
  throughout, marking it required or optional, followed by `- Default:` / `- Example:` /
  `- Note:` bullets as appropriate.

**Language: English.** Identifiers, descriptions, docs, commit messages, everything.

---

## Versioning

Three places declare a component's version and all three must agree:

```
metadata.json      { "version": { "major": 1, "minor": 0, "patch": 0 } }
<template>.bicep   metadata version = '1.0.0'
CHANGELOG.md       ## 1.0.0 - DD.MM.YYYY
```

The `version-sync` check fails the PR otherwise. Bump all three in the same commit — a
changelog that lags the code is worse than no changelog.

Semantic versioning: breaking parameter change → major; new optional parameter or capability
→ minor; fix with no contract change → patch.

---

## Things to flag rather than do

These are not forbidden. They are **not to be done silently** — call them out in your response
and in the PR description, because a reviewer reads them differently:

- Editing anything under `.github/workflows/`, `.github/agents/`, `.github/instructions/`,
  `AGENTS.md`, `CODEOWNERS`, `bicepconfig.json` or `ps-rule.yaml`. These define what agents
  are allowed to do; changing them from inside an agent session needs a human to look.
- Adding a rule exclusion to `ps-rule.yaml` or lowering a linter level in `bicepconfig.json`.
- Flipping any `deploymentFlags` value to `false`, or removing an entry from
  `parResourceGroups`. Under a deployment stack these delete real resources — read
  `patterns/*/docs/deployment-notes.md`.
- Setting `ALLOW_REAL_DEPLOY`, or adding a step that mutates Azure.
- Widening `permissions:` in a workflow, or adding `pull_request_target`.

---

## Definition of done

- [ ] Plan artefact exists under `docs/plans/` and matches what landed
- [ ] `bicep build` and `bicep build-params` clean on everything touched
- [ ] `validate-version-sync.sh` passes
- [ ] Versions bumped in all three places, if a component changed
- [ ] `CHANGELOG.md` entry written for a human, not a diff summary
- [ ] PR description states what was agent-authored and what you could not verify
- [ ] Nothing on the "flag rather than do" list happened without being flagged
