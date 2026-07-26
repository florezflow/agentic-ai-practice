//MARK: - METADATA
metadata name = 'Resource Group'
metadata owner = 'ACC-Platform'
metadata description = 'Creates a single resource group in the target subscription.'
metadata version = '1.0.0'
metadata type = 'Module'

//MARK: - DEPLOYMENT SCOPE
targetScope = 'subscription'

//MARK: - PARAMETERS
@description('''
![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Name of the resource group.
- Example: `tprac-core-csn-rg`
- Note: the caller is responsible for the naming convention; this module does not compose names.
''')
@minLength(1)
@maxLength(90)
param parResourceGroupName string

@description('''
![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Azure region the resource group metadata is stored in.
- Example: `switzerlandnorth`
''')
param parLocation string

@description('''
![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Tags applied to the resource group. Resources created inside it inherit these tags
only if the consuming template propagates them explicitly.
- Default: `{}`
''')
param parTags object = {}

//MARK: - RESOURCES
resource resResourceGroup 'Microsoft.Resources/resourceGroups@2025-03-01' = {
  name: parResourceGroupName
  location: parLocation
  tags: parTags
}

//MARK: - OUTPUTS
output resourceGroupName string = resResourceGroup.name
output resourceGroupId string = resResourceGroup.id
output resourceGroupLocation string = resResourceGroup.location
