---
applyTo: "**/*.bicepparam"
description: "Rules for parameter files — the highest-blast-radius files in the repo."
---

# Parameter files

A `.bicepparam` is template + values = a deployment. It is the unit PSRule analyses and the
unit the deploy workflow takes as input. It is also, line for line, the most dangerous file
type here: a one-character edit can delete an environment.

## Structure

```bicep
using '../../resource-groups.bicep'

// Run locally, exactly as the deploy workflow does:
// az deployment sub what-if \
//   --name gh600-<pattern>-<env> \
//   --location switzerlandnorth \
//   --parameters <this file>

param parBaseConfig = { ... }
param parResourceGroups = [ ... ]
```

The `using` line is a relative path to the pattern template. The comment block showing the
local what-if command is not decoration — it is how a reviewer reproduces what CI saw.

## Naming and placement

```
patterns/NNNN-<pattern>/configurations/<env>/<prefix>_NNNN-<pattern>_<env>.bicepparam
```

`<env>` must be `test` or `prod`, and must match the directory. The deploy workflow refuses to
run a configuration that does not live under `configurations/<selected environment>/`.

## Registering a new configuration

Adding the file is not enough. The `configuration` input in
`.github/workflows/deploy.yml` enumerates every deployable parameter file, and it is the only
such list. A configuration missing from it cannot be deployed — which is deliberate, but
surprising if you forget.

Editing `deploy.yml` is on the "flag it" list. Say so in the PR.

## Blast radius — read before editing

**Removing an entry from an array parameter is a deletion.** When the pattern is deployed as a
deployment stack with `--action-on-unmanage deleteAll`, anything that falls out of the template
becomes unmanaged and is destroyed, along with everything inside it.

**Flipping a `deploymentFlags` value to `false` is a bulk deletion.** It removes every resource
of that type from the template at once.

Neither of these looks dangerous in a diff. Both must be called out explicitly in the pull
request description, and the what-if output must be read before approval — not skimmed.

## Tags

`parBaseConfig.tags` is a typed contract; every field is required. Two carry meaning beyond
labelling:

- `IaC` must read `DeploymentStack: <pattern-folder> | Subscription: <subscription-name>`.
  This is the audit trail from a resource back to the deployment that owns it.
- `Description` should say what this *set* of resources is for, not restate the environment.

Per-entry `tags` are merged on top of the base tags, so they override. Use them for
entry-specific detail, not to restate what is already in the base.

## Secrets

There are none in this repo and there should be none. If a parameter ever needs a secret,
it must be `@secure()` in the template and supplied at deploy time from an environment
secret — never written into a `.bicepparam`. A committed secret in a public repository is
compromised the moment it is pushed, and rotating it is the only remedy.

## Verify

```bash
bicep build-params <file>.bicepparam --stdout > /dev/null
```

This catches type mismatches against the pattern's `artifacts/types.bicep`, which is most of
what goes wrong.
