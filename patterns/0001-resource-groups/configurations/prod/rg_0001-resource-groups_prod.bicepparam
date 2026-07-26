using '../../resource-groups.bicep'

// Run locally, exactly as the deploy workflow does:
// az deployment sub what-if \
//   --name gh600-0001-resource-groups-prod \
//   --location switzerlandnorth \
//   --parameters patterns/0001-resource-groups/configurations/prod/rg_0001-resource-groups_prod.bicepparam

param parBaseConfig = {
  prefix: 'pprac'
  suffix: 'csn'
  defaultLocation: 'switzerlandnorth'
  deploymentFlags: {
    resourceGroups: true
    locks: true
  }
  tags: {
    CostCenter: '0000'
    Creator: 'mflorez-bag'
    CreationDate: '26.07.2026'
    Description: 'GH-600 practice resource groups, prod environment'
    IaC: 'DeploymentStack: 0001-resource-groups | Subscription: gh600-prod'
  }
}

param parResourceGroups = [
  {
    name: 'core'
    enableLock: true
  }
  {
    name: 'data'
    enableLock: true
    lockLevel: 'CanNotDelete'
    tags: {
      Description: 'Data services for the practice workload'
    }
  }
  {
    // A name that must not be composed, e.g. because it predates the convention.
    name: 'legacy-shared-rg'
    setCustomName: true
    enableLock: true
  }
  // Cross-subscription example. Uncomment and set a real subscription ID to exercise the
  // `scope: subscription(...)` path in the pattern.
  // {
  //   name: 'shared'
  //   subscriptionId: '00000000-0000-0000-0000-000000000000'
  // }
]
