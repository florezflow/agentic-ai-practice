# Reference links

Every official documentation page this repository depends on, in one place. When a file in the
repo has a comment you don't understand, the relevant page is almost certainly listed below.

Ordered by how often you'll actually need it.

---

## GH-600 exam

| What | Link |
|---|---|
| **Study guide** — the objective list everything here maps to | <https://learn.microsoft.com/credentials/certifications/resources/study-guides/gh-600> |
| Certification page — logistics, booking | <https://learn.microsoft.com/credentials/certifications/agentic-ai-developer/> |
| Exam sandbox — try the question UI before the real thing | <https://ghcertdemo.starttest.com/> |
| Learn module — Foundations of Agentic AI in GitHub | <https://learn.microsoft.com/training/modules/foundations-agentic-ai/> |
| Learn module — Designing Agent Architecture and SDLC Integration | <https://learn.microsoft.com/training/modules/design-agent-architecture-integration/> |
| Learn module — Tooling, MCP, and Agent Execution Environments | <https://learn.microsoft.com/training/modules/agent-tooling-mcp-execution-environments/> |

## GitHub Agentic Workflows (`gh aw`)

The `.md` + `.lock.yml` pairs in `.github/workflows/`.

| What | Link |
|---|---|
| **Frontmatter reference** — every field in a workflow `.md` | <https://github.github.com/gh-aw/reference/frontmatter/> |
| **Safe outputs** — the only way an agentic workflow can write anything | <https://github.github.com/gh-aw/reference/safe-outputs/> |
| Triggers — `on:` syntax, including the friendly `daily` / `weekly` forms | <https://github.github.com/gh-aw/reference/triggers/> |
| Permissions — and how they couple to toolsets | <https://github.github.com/gh-aw/reference/permissions/> |
| Tools and toolsets | <https://github.github.com/gh-aw/reference/tools/> |
| Engines — `copilot`, `claude`, `codex`, `gemini` | <https://github.github.com/gh-aw/reference/engines/> |
| Network access control | <https://github.github.com/gh-aw/reference/network/> |
| Authentication — `COPILOT_GITHUB_TOKEN` vs `copilot-requests: write` | <https://github.github.com/gh-aw/reference/auth/> |
| Overview and concepts | <https://github.github.com/gh-aw/> |
| Source repository | <https://github.com/github/gh-aw> |

## Copilot agents and customization

| What | Link |
|---|---|
| **Custom agents configuration** — `.github/agents/*.agent.md` frontmatter, `tools:` aliases | <https://docs.github.com/copilot/reference/custom-agents-configuration> |
| **Custom instructions support matrix** — which surface reads which file. Read this one | <https://docs.github.com/copilot/reference/custom-instructions-support> |
| Adding repository custom instructions | <https://docs.github.com/copilot/how-tos/configure-custom-instructions/add-repository-instructions> |
| Configuring the development environment (`copilot-setup-steps.yml`) | <https://docs.github.com/copilot/how-tos/agents/copilot-coding-agent/customizing-the-development-environment-for-copilot-coding-agent> |
| MCP servers for the cloud agent | <https://docs.github.com/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/extend-cloud-agent-with-mcp> |
| Customizing or disabling the agent firewall | <https://docs.github.com/copilot/how-tos/use-copilot-agents/coding-agent/customize-the-agent-firewall> |
| Copilot allowlist reference | <https://docs.github.com/copilot/reference/copilot-allowlist-reference> |
| **Risks and mitigations** — what the cloud agent is prevented from doing | <https://docs.github.com/copilot/concepts/agents/cloud-agent/risks-and-mitigations> |
| Building guardrails for the cloud agent | <https://docs.github.com/copilot/tutorials/cloud-agent/build-guardrails> |
| Copilot Memory — the 28-day expiry | <https://docs.github.com/copilot/concepts/agents/copilot-memory> |
| Copilot CLI in GitHub Actions | <https://docs.github.com/copilot/concepts/agents/copilot-cli/copilot-cli-in-github-actions> |
| AGENTS.md — how to write a good one | <https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/> |

## GitHub platform — the gates

| What | Link |
|---|---|
| **Environments and deployment protection rules** — note the public/private plan limits | <https://docs.github.com/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments> |
| Rulesets — what replaced branch protection | <https://docs.github.com/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets> |
| CODEOWNERS syntax | <https://docs.github.com/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners> |
| Workflow `permissions:` and `GITHUB_TOKEN` | <https://docs.github.com/actions/security-for-github-actions/security-guides/automatic-token-authentication> |
| Workflow syntax reference | <https://docs.github.com/actions/reference/workflows-and-actions/workflow-syntax> |
| Variables and contexts (`vars.*`, `secrets.*`, `github.*`) | <https://docs.github.com/actions/reference/workflows-and-actions/contexts> |
| Code scanning and SARIF upload | <https://docs.github.com/code-security/code-scanning/integrating-with-code-scanning/uploading-a-sarif-file-to-github> |
| **OIDC to Azure** — how `azure/login` works without secrets | <https://docs.github.com/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-azure> |

## Azure — Bicep and deployment

| What | Link |
|---|---|
| Bicep documentation | <https://learn.microsoft.com/azure/azure-resource-manager/bicep/> |
| **Linter rules** — every rule in `bicepconfig.json` | <https://learn.microsoft.com/azure/azure-resource-manager/bicep/linter> |
| `bicepconfig.json` reference | <https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-config> |
| Parameter files (`.bicepparam`) | <https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameter-files> |
| User-defined data types (`artifacts/types.bicep`) | <https://learn.microsoft.com/azure/azure-resource-manager/bicep/user-defined-data-types> |
| Safe-dereference operator (`.?`) | <https://learn.microsoft.com/azure/azure-resource-manager/bicep/operator-safe-dereference> |
| **What-if** — and its known limitations | <https://learn.microsoft.com/azure/azure-resource-manager/templates/deploy-what-if> |
| **Deployment stacks** — why removing a resource deletes it | <https://learn.microsoft.com/azure/azure-resource-manager/bicep/deployment-stacks> |
| Management locks | <https://learn.microsoft.com/azure/azure-resource-manager/management/lock-resources> |
| Workload identity federation (the OIDC trust) | <https://learn.microsoft.com/entra/workload-id/workload-identity-federation> |
| PSRule for Azure | <https://azure.github.io/PSRule.Rules.Azure/> |
| Writing custom PSRule rules (`.ps-rule/`) | <https://microsoft.github.io/PSRule/v2/authoring-rules/> |

## CLI tools used here

| Tool | Link |
|---|---|
| `gh` — GitHub CLI | <https://cli.github.com/manual/> |
| `gh aw` — agentic workflows extension | <https://github.com/github/gh-aw> |
| `az` — Azure CLI | <https://learn.microsoft.com/cli/azure/> |
| `az deployment sub` | <https://learn.microsoft.com/cli/azure/deployment/sub> |
| `az stack sub` | <https://learn.microsoft.com/cli/azure/stack/sub> |
| `bicep` CLI | <https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-cli> |

---

## Things that are easy to get wrong

Each of these cost real time somewhere, and each has a page above:

- **Environment protection rules on a private repo need Enterprise.** On Free/Pro/Team they are
  public-repository only. This repo is public for that reason alone.
- **Environment variables and environment gates are coupled.** A job reading `vars.X` must
  declare `environment:` and inherits its approval gate — which is why the ungated `-preview`
  environments exist.
- **The agent firewall covers only Bash-tool processes.** Not MCP servers, not
  `copilot-setup-steps.yml`.
- **`copilot-setup-steps.yml`**: the job must be named `copilot-setup-steps`, or it is ignored
  with no error anywhere.
- **`AGENTS.md` and `*.instructions.md` are not read by chat on github.com.** Only
  `.github/copilot-instructions.md` is read by every surface.
- **Edit a workflow `.md` without running `gh aw compile`** and the old `.lock.yml` keeps
  running. Silently.
- **An OIDC `subject` must match exactly.** A typo fails at runtime with a generic error that
  names nothing useful.
