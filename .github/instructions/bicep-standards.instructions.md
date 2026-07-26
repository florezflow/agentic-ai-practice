---
applyTo: "**/*.bicep"
description: "Authoring standards for Bicep templates in this repository."
---

# Bicep standards

These apply to every `.bicep` file. They are loaded only when you are working with one, which
is why they can afford to be specific.

## Section order

Mandatory, with a `//MARK: - <SECTION>` comment introducing each:

```bicep
//MARK: - METADATA
metadata name = 'Human Readable Name'
metadata owner = 'ACC-Platform'
metadata description = 'One line, present tense, says what it creates.'
metadata version = '1.0.0'
metadata type = 'Module'          // or 'Pattern'

//MARK: - TYPES                    // patterns only
import { baseConfig } from 'artifacts/types.bicep'

//MARK: - DEPLOYMENT SCOPE
targetScope = 'subscription'

//MARK: - PARAMETERS               // @secure() parameters first

//MARK: - VARIABLES                // optional

//MARK: - RESOURCES

//MARK: - OUTPUTS                  // optional
```

`metadata version` must equal the version in the sibling `metadata.json` and have a matching
`## X.Y.Z` heading in `CHANGELOG.md`.

## Naming

| Kind | Convention | Example |
|---|---|---|
| Parameter | `par` + PascalCase | `parResourceGroupName` |
| Variable | `var` + PascalCase | `varResourceGroups` |
| Resource | `res` + PascalCase | `resResourceGroup` |
| Module | `mod` + PascalCase | `modLocks` |
| Output | no prefix, camelCase | `resourceGroupName` |

## Parameter descriptions

Every parameter carries an `@description()` opening with a badge, then a sentence, then bullets:

```bicep
@description('''
![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Name of the resource group.
- Example: `tprac-core-csn-rg`
- Note: the caller composes the name; this module does not.
''')
param parResourceGroupName string
```

Use `parameter-optional-green` for parameters with a default, and state the default in a
`- Default:` bullet. The badge is the first thing a reader sees in the generated docs, so it
must match reality.

## Patterns to follow

**Resolve optionals exactly once**, then loop over the resolved array. This keeps the module
calls readable and gives defaults a single home:

```bicep
var varResourceGroups = [
  for rg in parResourceGroups: {
    name: (rg.?setCustomName ?? false) ? rg.name : '${parBaseConfig.prefix}-${rg.name}-${parBaseConfig.suffix}-rg'
    location: rg.?location ?? parBaseConfig.defaultLocation
    subscriptionId: rg.?subscriptionId ?? subscription().subscriptionId
  }
]
```

**Guard every module loop with a deployment flag:**

```bicep
module modLocks '../../modules/resources/locks/main.bicep' = [
  for rg in varResourceGroups: if (parBaseConfig.deploymentFlags.locks && rg.enableLock) {
```

**Merge tags low-to-high** so the most specific value wins:

```bicep
tags: union(parBaseConfig.tags, { LastModified: parLastModified }, rg.?tags ?? {})
```

## Anti-patterns

| Do not | Instead |
|---|---|
| `rg.location!` | `rg.?location ?? <default>` |
| Redefine a type inline | Import it from `artifacts/types.bicep` |
| Repeat `??` in both the `var` block and the module call | Default once, in the `var` block |
| Remove a `dependsOn` because it "looks redundant" | Check whether the `scope:` is a plain string — if so it is load-bearing |
| Hardcode a subscription ID in a template | Take it as a parameter; hardcode in the `.bicepparam` |
| Add an output that echoes an input | Output only what the caller cannot already know |

## Modules vs patterns

A module does one thing, takes plain parameters, and composes nothing. It must not read
`resourceGroup().tags`, invent names, or know which environment it is in.

A pattern composes modules and owns naming, tag inheritance, scope resolution and deployment
flags. When unsure where logic belongs: *would a different pattern want this to be different?*
If yes, it belongs in the pattern.

## Verify

```bash
bicep build <file>.bicep --stdout > /dev/null
```

Warnings are not noise. If the linter warns, either fix it or explain in the PR why it is
acceptable here. Do not lower the rule level in `bicepconfig.json` — that is a change to the
gate itself and must be flagged.
