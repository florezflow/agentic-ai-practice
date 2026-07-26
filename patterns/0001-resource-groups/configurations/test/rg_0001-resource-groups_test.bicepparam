using '../../resource-groups.bicep'

// Run locally, exactly as the deploy workflow does:
// az deployment sub what-if \
//   --name gh600-0001-resource-groups-test \
//   --location switzerlandnorth \
//   --parameters patterns/0001-resource-groups/configurations/test/rg_0001-resource-groups_test.bicepparam

param parBaseConfig = {
  prefix: 'tprac'
  suffix: 'csn'
  defaultLocation: 'switzerlandnorth'
  deploymentFlags: {
    resourceGroups: true
    // Locks stay off in test so the environment can be torn down without ceremony.
    locks: false
  }
  tags: {
    CostCenter: '0000'
    Creator: 'mflorez-bag'
    CreationDate: '26.07.2026'
    Description: 'GH-600 practice resource groups, test environment'
    IaC: 'DeploymentStack: 0001-resource-groups | Subscription: gh600-test'
  }
}

param parResourceGroups = [
  {
    name: 'core'
  }
  {
    name: 'data'
    tags: {
      Description: 'Data services for the practice workload'
    }
  }
  {
    name: 'monitoring'
    location: 'westeurope'
  }
]
