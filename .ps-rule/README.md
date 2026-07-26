# Custom PSRule rules

The `microsoft/ps-rule` action reads custom rules from this directory (`-Source '.ps-rule/'`).
It is empty for now — every rule in the `psrule` check comes from the `PSRule.Rules.Azure`
module.

Put repo-specific rules here when a convention needs enforcing that the Azure baseline does not
cover, for example:

- resource group names must match `<prefix>-<name>-<suffix>-rg`
- the `IaC` tag must carry a `DeploymentStack:` marker
- prod configurations must set `deploymentFlags.locks: true`

Rules can be written in YAML or PowerShell. See
<https://microsoft.github.io/PSRule/v2/authoring-rules/>.

Writing one is a good Domain 4 exercise: it turns a convention that currently lives in prose
(`AGENTS.md`) into an automated evaluation signal an agent gets feedback from.
