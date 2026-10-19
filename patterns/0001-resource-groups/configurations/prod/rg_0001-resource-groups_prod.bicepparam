// A .bicepparam is template + values = one deployment. `using` points at the template; the
// parameter names and types below are checked against it at build time.
// Reference: https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameter-files
//
// This file must also be listed in the `configuration` input of .github/workflows/deploy.yml —
// that list is the only enumeration of deployable configurations.
//
// Highest blast radius file type in the repo: removing an entry from an array parameter, or
// flipping a deploymentFlags value to false, DELETES resources when deployed as a stack.
// See docs/deployment-notes.md in this pattern before editing.

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
    Creator: 'florezflow'
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
