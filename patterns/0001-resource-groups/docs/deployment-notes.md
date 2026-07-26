# 0001-resource-groups — deployment notes

## What this pattern does

Takes one array parameter (`parResourceGroups`) and creates one resource group per entry,
optionally locking each one. All naming, tagging and scope resolution happens here; the
modules underneath stay dumb.

```
parResourceGroups[]  ──▶  varResourceGroups[]  ──▶  modResourceGroups[]  (subscription scope)
                                              └──▶  modLocks[]           (resourceGroup scope)
```

## Name composition

```
<prefix>-<name>-<suffix>-rg          e.g.  tprac + core + csn  ->  tprac-core-csn-rg
```

Set `setCustomName: true` on an entry to bypass composition and use `name` verbatim. This is
the escape hatch for resources that predate the convention — use it sparingly, because the
composed form is what makes the environment scannable.

## Tag precedence

Tags are merged low-to-high, so the most specific value wins:

```
parBaseConfig.tags  <  { LastModified }  <  entry.tags
```

`LastModified` is stamped from `utcNow('dd.MM.yyyy')` at deployment time. That means **every
deployment shows a tag change in what-if**, on every resource group. This is expected noise;
do not "fix" it by removing the tag, and do not let it hide a real change — read past it.

## Deployment flags

`parBaseConfig.deploymentFlags` are master switches:

| Flag | `true` | `false` |
|---|---|---|
| `resourceGroups` | Resource groups are managed by this deployment | Resource groups are **not** in the template |
| `locks` | Locks applied to entries with `enableLock: true` | No locks in the template |

> **Setting a flag to `false` is not the same as "skip".** With a plain
> `az deployment sub create` it simply omits the resources. With a **deployment stack** and
> `--action-on-unmanage deleteAll`, resources that fall out of the template become unmanaged
> and are deleted. A single flag flip can therefore delete every resource group and everything
> inside them.
>
> Always read the what-if artefact produced by the `whatif` job before approving a deploy.

## Cross-subscription placement

Omit `subscriptionId` and the resource group lands in the subscription the deployment runs in.
Set it, and the pattern uses `scope: subscription(<id>)` for the resource group and
`scope: resourceGroup(<id>, <name>)` for the lock. The deploying identity needs permissions in
that subscription too — a cross-subscription failure surfaces as an authorization error on the
nested deployment, not on the top-level one.

## Locks

`modLocks` has an explicit `dependsOn: [modResourceGroups]`. This is deliberate and must not be
removed: the lock module's `scope:` is a plain string expression, so Bicep sees no dependency
between creating a resource group and locking it. Without `dependsOn` the deployment fails
intermittently, depending on ordering.

`ReadOnly` locks block *changes*, including subsequent IaC runs against the same resource
group. `CanNotDelete` is almost always what you want.

## Running it

```bash
# Preview — this is all CI ever does
az deployment sub what-if \
  --name gh600-0001-resource-groups-test \
  --location switzerlandnorth \
  --subscription <subscription-id> \
  --parameters patterns/0001-resource-groups/configurations/test/rg_0001-resource-groups_test.bicepparam

# Validate — also non-mutating
az deployment sub validate \
  --location switzerlandnorth \
  --subscription <subscription-id> \
  --parameters patterns/0001-resource-groups/configurations/test/rg_0001-resource-groups_test.bicepparam
```

The real deployment command is intentionally **not** run by this repo. It is kept here for
reference only, and in the workflow it sits behind the `ALLOW_REAL_DEPLOY` repository variable:

```bash
az stack sub create \
  --name 0001-resource-groups \
  --location switzerlandnorth \
  --action-on-unmanage deleteAll \
  --deny-settings-mode none \
  --subscription <subscription-id> \
  --parameters <bicepparam> \
  --bse --yes
```

## Adding a configuration

1. Add the `.bicepparam` under `configurations/test/` or `configurations/prod/`.
2. Add its path to the `configuration` input choices in `.github/workflows/deploy.yml`.
   The workflow's choice list is the only place that enumerates configurations — a parameter
   file that is not listed there cannot be deployed.
3. Run `bicep build-params` on it locally before opening the PR; the `lint` check does the same.
