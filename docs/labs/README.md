# Labs

One lab per GH-600 domain. Each has an objective, concrete steps, a **Verify** section with
something checkable, and a "What the exam asks" section covering the distinctions that turn up
as questions.

| # | Lab | Domain | Weight |
|---|---|---|---|
| 1 | [Agent architecture and SDLC](01-agent-architecture.md) | Prepare agent architecture and SDLC processes | 15–20% |
| 2 | [Tool use and MCP](02-tools-and-mcp.md) | Implement tool use and environment interaction | 20–25% |
| 3 | [Memory and state](03-memory-and-state.md) | Manage memory, state, and execution | 10–15% |
| 4 | [Evaluation and tuning](04-evaluation-and-tuning.md) | Perform evaluation, error analysis, and tuning | 15–20% |
| 5 | [Multi-agent coordination](05-multi-agent.md) | Orchestrate multi-agent coordination | 15–20% |
| 6 | [Guardrails and accountability](06-guardrails.md) | Implement guardrails and accountability | 10–15% |

Full objective-by-objective mapping: [`../gh600-domain-map.md`](../gh600-domain-map.md).

## Prerequisites

| Needed for | What |
|---|---|
| Labs 1, 2, 5 | A paid Copilot plan — the cloud agent requires one |
| Lab 2 Part F, Lab 5 | `COPILOT_GITHUB_TOKEN` repository secret (personal repos only) |
| Lab 4 | Nothing beyond the repo — `psrule` already runs on every PR |
| Lab 6 | Repository admin, which you have |
| Optional, everywhere | Azure OIDC — the deploy workflow degrades to a clean skip without it |

```bash
gh secret set COPILOT_GITHUB_TOKEN --repo mflorez-bag/agentic-ai-practice
```

## Order

1, 2 and 6 first — they establish the architecture, the tool model and the gates. 3 and 4 build
on 1. 5 needs everything else in place.

Lab 6 Part A is worth doing early even out of order: it documents how the repository's own
gates were configured, and confirms they still are.

## Ground rules

- **Restore what you break.** Several labs ask you to break something on purpose. Each says how
  to put it back — do it before moving on, or the next lab starts from a broken baseline.
- **Two settings must be turned back off**: `require_code_owner_review` (Lab 1 Part C and
  Lab 6 Part D) and repository visibility (Lab 6 Part C). Leaving either deadlocks a solo repo.
- **Read the failures.** The most useful moments here are the ones where something does not work
  — the ignored `copilot-setup-steps` job name, the PSRule expansion error, the missing
  `COPILOT_GITHUB_TOKEN`. Those are the exam questions.

## Azure OIDC (optional)

Only the `whatif` job uses it, and it self-skips when unset. To enable, create an Entra app
registration with federated credentials for these subjects:

```
repo:mflorez-bag/agentic-ai-practice:environment:test
repo:mflorez-bag/agentic-ai-practice:environment:prod
repo:mflorez-bag/agentic-ai-practice:environment:test-preview
repo:mflorez-bag/agentic-ai-practice:environment:prod-preview
```

Grant it **Contributor** on a sandbox subscription — subscription-scope `what-if` needs
`Microsoft.Resources/deployments/whatIf/action`, which Reader does not include. Then set
`AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` and `AZURE_LOCATION` as
**variables** (not secrets — OIDC stores no credentials) on all four environments.

`ALLOW_REAL_DEPLOY` stays `false`. Nothing is ever created.
