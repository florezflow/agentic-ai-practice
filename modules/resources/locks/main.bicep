//MARK: - METADATA
metadata name = 'Resource Lock'
metadata owner = 'ACC-Platform'
metadata description = 'Applies a management lock to the scope the module is deployed into.'
metadata version = '1.0.0'
metadata type = 'Module'

//MARK: - DEPLOYMENT SCOPE
targetScope = 'resourceGroup'

//MARK: - PARAMETERS
@description('''
![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Name of the management lock.
- Default: `ResourceGroupLock`
''')
param parLockName string = 'ResourceGroupLock'

@description('''
![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Lock level.
- Default: `CanNotDelete`
- Note: `ReadOnly` also blocks changes to resources inside the scope and is disruptive
  for most workloads. Prefer `CanNotDelete` unless you mean it.
''')
param parLockLevel ('CanNotDelete' | 'ReadOnly') = 'CanNotDelete'

@description('''
![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Free-text note shown to anyone who hits the lock in the portal. Say who to ask.
- Default: `Managed by IaC. Remove through the pipeline, not manually.`
''')
param parNotes string = 'Managed by IaC. Remove through the pipeline, not manually.'

//MARK: - RESOURCES
resource resLock 'Microsoft.Authorization/locks@2020-05-01' = {
  name: parLockName
  properties: {
    level: parLockLevel
    notes: parNotes
  }
}

//MARK: - OUTPUTS
output lockName string = resLock.name
output lockId string = resLock.id
