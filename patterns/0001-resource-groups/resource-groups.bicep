// Reference:
//   Bicep language          https://learn.microsoft.com/azure/azure-resource-manager/bicep/
//   user-defined types      https://learn.microsoft.com/azure/azure-resource-manager/bicep/user-defined-data-types
//   safe dereference (.?)   https://learn.microsoft.com/azure/azure-resource-manager/bicep/operator-safe-dereference
//   loops                   https://learn.microsoft.com/azure/azure-resource-manager/bicep/loops
//   deployment stacks       https://learn.microsoft.com/azure/azure-resource-manager/bicep/deployment-stacks
//   all links               docs/reference-links.md

//MARK: - METADATA
metadata name = 'Resource Groups'
metadata owner = 'ACC-Platform'
metadata description = 'Creates a list of resource groups with optional management locks, driven by a single array parameter.'
metadata version = '1.0.0'
metadata type = 'Pattern'

//MARK: - TYPES
import { baseConfig, resourceGroupConfig } from 'artifacts/types.bicep'

//MARK: - DEPLOYMENT SCOPE
targetScope = 'subscription'

//MARK: - PARAMETERS
@description('''
![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Base configuration: naming affixes, default region, deployment flags and standard tags.
''')
param parBaseConfig baseConfig

@description('''
![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

The resource groups to create. Add an entry to create one; remove an entry to stop managing it.
- Note: when deployed as a deployment stack with `--action-on-unmanage deleteAll`, removing an
  entry deletes the resource group and everything in it. Read the what-if output first.
''')
@minLength(1)
param parResourceGroups resourceGroupConfig[]

@description('''
![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Deployment date written to the `LastModified` tag. Leave at the default; it is only a
parameter because `utcNow()` may not be used outside a parameter default.
''')
param parLastModified string = utcNow('dd.MM.yyyy')

//MARK: - VARIABLES
// Resolve every optional property exactly once, so the module loops below stay readable and
// the composed names are computed in a single place.
var varResourceGroups = [
  for rg in parResourceGroups: {
    name: (rg.?setCustomName ?? false)
      ? rg.name
      : '${parBaseConfig.prefix}-${rg.name}-${parBaseConfig.suffix}-rg'
    location: rg.?location ?? parBaseConfig.defaultLocation
    subscriptionId: rg.?subscriptionId ?? subscription().subscriptionId
    enableLock: rg.?enableLock ?? false
    lockLevel: rg.?lockLevel ?? 'CanNotDelete'
    tags: union(
      parBaseConfig.tags,
      {
        LastModified: parLastModified
      },
      rg.?tags ?? {}
    )
  }
]

//MARK: - RESOURCES
module modResourceGroups '../../modules/resources/resource-group/main.bicep' = [
  for rg in varResourceGroups: if (parBaseConfig.deploymentFlags.resourceGroups) {
    scope: subscription(rg.subscriptionId)
    name: 'create-rg-${rg.name}'
    params: {
      parResourceGroupName: rg.name
      parLocation: rg.location
      parTags: rg.tags
    }
  }
]

module modLocks '../../modules/resources/locks/main.bicep' = [
  for rg in varResourceGroups: if (parBaseConfig.deploymentFlags.locks && rg.enableLock) {
    scope: resourceGroup(rg.subscriptionId, rg.name)
    name: 'create-lock-${rg.name}'
    params: {
      parLockLevel: rg.lockLevel
      parNotes: 'Managed by 0001-resource-groups. Remove through the pipeline, not manually.'
    }
    // The scope above is a plain string, so nothing links these modules implicitly.
    dependsOn: [
      modResourceGroups
    ]
  }
]

//MARK: - OUTPUTS
output resourceGroupNames string[] = [for rg in varResourceGroups: rg.name]
output lockedResourceGroupNames string[] = filter(
  map(varResourceGroups, rg => rg.enableLock ? rg.name : ''),
  name => !empty(name)
)
