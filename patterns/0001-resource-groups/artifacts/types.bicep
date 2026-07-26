//MARK: - METADATA
metadata name = 'Resource Groups Pattern Types'
metadata description = 'Type definitions for the 0001-resource-groups pattern.'

//MARK: - TYPES
@export()
@description('Tags every resource created by this pattern carries.')
type defaultTags = {
  @description('Cost centre the resources are billed to. Example: `0000`')
  CostCenter: string

  @description('Mailbox that owns the resources. Example: `platform@example.com`')
  Creator: string

  @description('Date the configuration was first created, `DD.MM.YYYY`.')
  CreationDate: string

  @description('What this set of resource groups is for, in one line.')
  Description: string

  @description('''
  Audit marker linking the resource back to the deployment that owns it.
  - Format: `DeploymentStack: <pattern-folder> | Subscription: <subscription-name>`
  ''')
  IaC: string
}

@export()
@description('''
Master switches for this pattern.

**A flag set to `false` does not merely skip creation.** When the pattern is deployed as a
deployment stack with `--action-on-unmanage deleteAll`, resources of that type that already
exist become unmanaged and are deleted. Always read the what-if output before flipping one.
''')
type deploymentFlags = {
  @description('Create the resource groups.')
  resourceGroups: bool

  @description('Apply management locks to resource groups that opt in via `enableLock`.')
  locks: bool
}

@export()
@description('Base configuration shared by every resource group in the deployment.')
type baseConfig = {
  @description('Environment/tenant prefix used to compose names. Example: `tprac`')
  prefix: string

  @description('Region suffix used to compose names. Example: `csn`')
  suffix: string

  @description('Region used when a resource group does not specify its own.')
  defaultLocation: azureLocation

  @description('Master switches, see `deploymentFlags`.')
  deploymentFlags: deploymentFlags

  @description('Tags merged into every resource group.')
  tags: defaultTags
}

@export()
@description('Regions this practice repo allows. Kept short on purpose.')
type azureLocation = 'switzerlandnorth' | 'switzerlandwest' | 'westeurope' | 'germanywestcentral'

@export()
@description('One resource group to create.')
type resourceGroupConfig = {
  @description('''
  Short name of the resource group.
  - Composed as `<prefix>-<name>-<suffix>-rg` unless `setCustomName` is `true`.
  - Example: `core` becomes `tprac-core-csn-rg`
  ''')
  name: string

  @description('Use `name` verbatim instead of composing it. Default: `false`')
  setCustomName: bool?

  @description('Override the region for this resource group. Default: `baseConfig.defaultLocation`')
  location: azureLocation?

  @description('''
  Target subscription. Default: the subscription the deployment runs in.
  Set this to place a resource group in a different subscription.
  ''')
  subscriptionId: string?

  @description('Apply a management lock to this resource group. Default: `false`')
  enableLock: bool?

  @description('Lock level when `enableLock` is `true`. Default: `CanNotDelete`')
  lockLevel: ('CanNotDelete' | 'ReadOnly')?

  @description('Extra tags merged on top of `baseConfig.tags` for this resource group only.')
  tags: object?
}
