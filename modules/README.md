# Modules

Reusable Bicep building blocks. A module does one thing, takes scalar/typed parameters, and
never composes names or invents conventions — that is the pattern layer's job
(see [`../patterns/`](../patterns/)).

Modules are consumed **by relative path** from patterns. This repo has no Azure Container
Registry, so there are no `br:` module references and `bicepconfig.json` declares no
`moduleAliases`.

## Conventions

Every module directory contains exactly:

```
<category>/<module-name>/
├── main.bicep       # //MARK: sections in fixed order
├── metadata.json    # { "version": { major, minor, patch }, "level": n }
└── CHANGELOG.md     # ## X.Y.Z - DD.MM.YYYY
```

`main.bicep` section order is mandatory and checked in review:

```
//MARK: - METADATA
//MARK: - DEPLOYMENT SCOPE
//MARK: - PARAMETERS      @secure() parameters first
//MARK: - VARIABLES       optional
//MARK: - RESOURCES
//MARK: - OUTPUTS         optional
```

Naming: `par*` parameters, `var*` variables, `res*` resources, `mod*` modules, outputs
unprefixed camelCase, files and folders kebab-case.

`metadata version` in `main.bicep`, the version in `metadata.json`, and the newest heading in
`CHANGELOG.md` must all agree. The `version-sync` status check fails the PR if they drift.

`level` controls publishing order in registry-backed repos (1 = no dependencies on other
modules). Nothing here publishes, but the field is kept so the layout matches the real thing.

There are deliberately **no per-module `README.md` files**: in the upstream repo this
pattern is modelled on, module READMEs are generated from the Bicep metadata by a pipeline.
Rather than hand-maintain a copy that will rot, the parameter contracts live here.

---

## `resources/resource-group` — v1.0.0

Creates a single resource group. Scope: `subscription`.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `parResourceGroupName` | `string` (1–90) | yes | Name of the resource group. The caller composes it. |
| `parLocation` | `string` | yes | Region the resource group metadata lives in, e.g. `switzerlandnorth`. |
| `parTags` | `object` | no (`{}`) | Tags applied to the resource group. |

| Output | Type |
|---|---|
| `resourceGroupName` | `string` |
| `resourceGroupId` | `string` |
| `resourceGroupLocation` | `string` |

Because it targets `subscription` scope, a consuming template can create resource groups in
*other* subscriptions:

```bicep
module modResourceGroup '../../modules/resources/resource-group/main.bicep' = {
  scope: subscription('00000000-0000-0000-0000-000000000000')
  name: 'create-rg-core'
  params: {
    parResourceGroupName: 'tprac-core-csn-rg'
    parLocation: 'switzerlandnorth'
    parTags: { CostCenter: '0000', IaC: 'DeploymentStack: 0001-resource-groups' }
  }
}
```

The tag parameter is a plain `object`, not a typed tag contract, so the module stays usable
from any pattern. Type enforcement belongs one layer up.

---

## `resources/locks` — v1.0.0

Applies a management lock to the scope it is deployed into. Scope: `resourceGroup`.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `parLockName` | `string` | no (`ResourceGroupLock`) | Name of the management lock. |
| `parLockLevel` | `'CanNotDelete' \| 'ReadOnly'` | no (`CanNotDelete`) | Lock level. |
| `parNotes` | `string` | no | Note shown to anyone who hits the lock in the portal. |

| Output | Type |
|---|---|
| `lockName` | `string` |
| `lockId` | `string` |

Placement is controlled entirely by the caller's `scope:`; there is no "which resource group"
parameter by design:

```bicep
module modLock '../../modules/resources/locks/main.bicep' = {
  scope: resourceGroup('00000000-0000-0000-0000-000000000000', 'tprac-core-csn-rg')
  name: 'create-lock-core'
  params: {
    parLockLevel: 'CanNotDelete'
  }
  dependsOn: [ modResourceGroup ]
}
```

Two things that bite:

- `dependsOn` is **required** when the target scope is created in the same deployment. The
  `scope:` expression is a plain string and creates no implicit dependency.
- `ReadOnly` blocks *changes* to every resource inside the scope, not just deletion — including
  subsequent IaC runs. Use `CanNotDelete` unless you specifically want a frozen scope.
