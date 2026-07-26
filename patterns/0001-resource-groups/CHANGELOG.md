# CHANGELOG

All notable changes to this pattern are documented here. Every entry must match the version
in `metadata.json` and the `metadata version` declaration in `resource-groups.bicep` — the
`version-sync` status check enforces this.

## 1.0.0 - 26.07.2026

Features (MFL):

- First version of this pattern. Loops `parResourceGroups` and creates one resource group per
  entry via `modules/resources/resource-group`, with optional management locks via
  `modules/resources/locks`.
- Supports cross-subscription placement (`subscriptionId`), per-entry region and tag overrides,
  custom names (`setCustomName`), and master switches through `deploymentFlags`.
