---
name: new-pattern
description: Scaffold a new numbered pattern under patterns/ with its template, types, metadata, changelog, test and prod configurations, and deployment notes. Use when starting a new composition of existing modules.
---

# new-pattern

Creates the full skeleton of a pattern so that nothing is forgotten — a pattern missing its
`metadata.json` fails `version-sync`, and one missing a `.bicepparam` fails `lint`.

## Input

- A number: the next unused `NNNN` under `patterns/`.
- A kebab-case name.
- Which modules it will compose.

## Plan first

This is more than a one-line edit, so write `docs/plans/<name>-pattern.md` and wait for
agreement before creating files. See `AGENTS.md`.

## Files to create

```
patterns/NNNN-<name>/
├── <name>.bicep                                    # note: the number is dropped here
├── metadata.json                                   # { "version": {1,0,0}, "level": 1, "iac-managed": true }
├── CHANGELOG.md                                    # ## 1.0.0 - DD.MM.YYYY
├── artifacts/types.bicep                           # @export()ed baseConfig + item type
├── configurations/test/<prefix>_NNNN-<name>_test.bicepparam
├── configurations/prod/<prefix>_NNNN-<name>_prod.bicepparam
└── docs/deployment-notes.md
```

Use `patterns/0001-resource-groups/` as the reference. Copy its shape, not its content.

## Template skeleton

```bicep
//MARK: - METADATA
metadata name = '<Human Readable>'
metadata owner = 'ACC-Platform'
metadata description = '<one line, present tense>'
metadata version = '1.0.0'
metadata type = 'Pattern'

//MARK: - TYPES
import { baseConfig, <itemType> } from 'artifacts/types.bicep'

//MARK: - DEPLOYMENT SCOPE
targetScope = 'subscription'

//MARK: - PARAMETERS
param parBaseConfig baseConfig
param par<Items> <itemType>[]
param parLastModified string = utcNow('dd.MM.yyyy')

//MARK: - VARIABLES
// Resolve every optional property exactly once.

//MARK: - RESOURCES
// One module loop per resource kind, each guarded by a deploymentFlags check.

//MARK: - OUTPUTS
```

`baseConfig` must carry `prefix`, `suffix`, `defaultLocation`, `deploymentFlags` and `tags`.
Add one boolean to `deploymentFlags` per resource kind the pattern manages.

## After creating the files

1. Build:

   ```bash
   bicep build patterns/NNNN-<name>/<name>.bicep --stdout > /dev/null
   bicep build-params patterns/NNNN-<name>/configurations/test/*.bicepparam --stdout > /dev/null
   bicep build-params patterns/NNNN-<name>/configurations/prod/*.bicepparam --stdout > /dev/null
   bash .github/scripts/validate-version-sync.sh
   ```

2. **Register the configurations** in the `configuration` input of
   `.github/workflows/deploy.yml`. That list is the only enumeration of deployable parameter
   files; a configuration missing from it cannot be deployed.

   Editing a workflow is on the "flag it" list — say so explicitly in your response and in the
   pull request description.

3. Add a row to the table in `patterns/README.md`.

## Do not

- Do not put the number in the template filename. `0001-resource-groups/resource-groups.bicep`.
- Do not define types inline. They belong in `artifacts/types.bicep` with `@export()`.
- Do not create a pattern that manages a single resource with no options. That is a module.
