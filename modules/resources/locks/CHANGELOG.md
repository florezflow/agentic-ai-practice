# CHANGELOG

All notable changes to this module are documented here. Every entry must match the version
in `metadata.json` and the `metadata version` declaration in `main.bicep` — the `version-sync`
status check enforces this.

## 1.0.0 - 26.07.2026

Features (MFL):

- First version of this module. Applies a `Microsoft.Authorization/locks` resource to the
  scope it is deployed into, with configurable name, level and note.
