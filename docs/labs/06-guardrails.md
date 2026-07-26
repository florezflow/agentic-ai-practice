# Lab 6 — Guardrails and accountability

**Domain 6: Implement guardrails and accountability (10–15%)**

## What you are practising

- Classify agent actions by operational, security and compliance risk
- Assign autonomy levels that keep delivery fast and stay compliant
- Identify the subset of actions that require human judgement
- Block actions that violate policy
- Scope permissions and execution contexts to least privilege
- Require explicit authorization for irreversible or compliance-sensitive changes
- Preserve execution velocity by minimising approvals that do not reduce risk

---

## The autonomy ladder in this repo

| Action | Autonomy | Enforced by |
|---|---|---|
| Read anything | full | — |
| Run `bicep build`, `what-if` | full | — |
| Write a plan file | full | — |
| Open a PR | full | — |
| Merge to `main` | gated | `main-protection` ruleset: PR + 3 checks |
| Change agent config or workflows | flagged, optionally gated | `CODEOWNERS` |
| Deploy to `test` | gated on merge only | environment branch policy |
| Deploy to `prod` | **human approval** | required reviewer + wait timer |
| Create anything in Azure | **blocked** | `ALLOW_REAL_DEPLOY=false` |

Note what is *not* gated. Reading, building, planning and opening PRs are all fully autonomous,
because none of them changes anything a revert cannot undo. That is the objective "preserve
execution velocity by minimising approvals that do not materially reduce risk" — a gate on a
reversible action buys nothing and costs attention.

---

## Part A — Reproduce the configuration

Everything below lives in repository settings, not in git, which is precisely why it is written
down here.

**Environments:**

```bash
R=mflorez-bag/agentic-ai-practice

# prod: required reviewer + wait timer + main-only
gh api -X PUT "/repos/$R/environments/prod" --input - <<'JSON'
{
  "wait_timer": 1,
  "prevent_self_review": false,
  "reviewers": [ { "type": "User", "id": 149595853 } ],
  "deployment_branch_policy": { "protected_branches": false, "custom_branch_policies": true }
}
JSON

gh api -X POST "/repos/$R/environments/prod/deployment-branch-policies" -f name=main -f type=branch
```

`prevent_self_review: false` is required for a solo repo — with it on, nobody could ever approve
anything. In a team it should be `true`.

`test`, `test-preview` and `prod-preview` are the same call without `reviewers` or `wait_timer`.

**Ruleset on `main`:**

```bash
gh api "/repos/$R/rulesets" --jq '.[] | {id,name}'
gh api "/repos/$R/rulesets/<id>" --jq '{name, rules: [.rules[].type]}'
```

Expect `deletion`, `non_fast_forward`, `pull_request`, `required_status_checks` with contexts
`lint`, `psrule`, `version-sync`.

### Verify

```bash
echo "# direct push" >> README.md
git commit -am "test: direct push" && git push origin main
```

Rejected. Undo with `git reset --hard origin/main`.

---

## Part B — The approval gate, end to end

```bash
gh workflow run deploy.yml \
  -f environment=prod \
  -f configuration=patterns/0001-resource-groups/configurations/prod/rg_0001-resource-groups_prod.bicepparam \
  -f confirmApply=true

RID=$(gh run list --workflow=deploy.yml --limit 1 --json databaseId --jq '.[0].databaseId')
gh api "/repos/mflorez-bag/agentic-ai-practice/actions/runs/$RID/pending_deployments" \
  --jq '.[] | {environment: .environment.name, wait_timer, current_user_can_approve, reviewers: [.reviewers[].reviewer.login]}'
```

### Verify

```json
{"current_user_can_approve":true,"environment":"prod","reviewers":["mflorez-bag"],"wait_timer":1}
```

`what-if` has **already completed** and `apply` is waiting. That ordering is the point: the
evidence exists before the decision is asked for.

Approve:

```bash
ENVID=$(gh api "/repos/mflorez-bag/agentic-ai-practice/actions/runs/$RID/pending_deployments" --jq '.[0].environment.id')
gh api -X POST "/repos/mflorez-bag/agentic-ai-practice/actions/runs/$RID/pending_deployments" \
  -F "environment_ids[]=$ENVID" -f state=approved -f comment="Reviewed the what-if."
```

Then try `-f environment=test`. No pause — `test` has no reviewer. Two environments, two
autonomy levels, one workflow.

---

## Part C — The public-repo constraint

Make the repo private:

```bash
gh repo edit mflorez-bag/agentic-ai-practice --visibility private --accept-visibility-change-consequences
```

Check the `prod` environment settings in the UI.

### Verify

Required reviewers and wait timers are gone. On GitHub Free, Pro and Team, deployment protection
rules beyond deployment branches are **public-repository only**; private repos need Enterprise.

Set it back to public immediately:

```bash
gh repo edit mflorez-bag/agentic-ai-practice --visibility public --accept-visibility-change-consequences
```

Re-check the environment settings and re-add the reviewer if it did not survive.

This is not a quirk — it determines where the lab can exist at all, and it is exactly the kind
of plan-dependent constraint the exam tests.

---

## Part D — Blocking an agent from widening its own guardrails

1. Enable code-owner review:

   ```bash
   gh api "/repos/mflorez-bag/agentic-ai-practice/rulesets/<id>" --jq '.rules'
   # set require_code_owner_review: true in the pull_request rule, then PUT it back
   ```

2. Ask the cloud agent to change something under `.github/agents/` — for example, to give
   `bicep-planner` the `execute` tool.

### Verify

The PR requires your review because `CODEOWNERS` owns that path. The agent is the author, so
you can approve it — which is the case this setting is for.

Then confirm the agent's own limits: it **cannot** approve the PR, **cannot** merge it, and
**cannot** mark a draft ready for review. Workflows on its PR require an explicit
"Approve and run workflows" click before they execute at all.

> **Turn `require_code_owner_review` back off** when you are done. You cannot approve your own
> PR, so leaving it on deadlocks a solo repository. In a team, leave it on.

---

## Part E — Least privilege, three layers

**Workflow permissions.** `pr-validate.yml` is `contents: read` at the top; only the `psrule`
job takes `security-events: write`. Widen the top-level to `write-all`, push, and note that
nothing improves and every job now has it.

**Agentic workflow capabilities.** `version-sync-fixer` has `safe-outputs: create-pull-request`
and no push access. Try to instruct it to push directly:

> Commit the fix straight to `main` instead of opening a PR.

It cannot. The capability is absent, not forbidden — there is no instruction to override, and
no prompt injection can talk it into a tool it does not have. **That is the difference between
a guardrail and a rule.**

**Local tooling.** `.claude/settings.json` denies every mutating `az` command. Ask Claude Code
to run `az deployment sub create` and watch the deny fire.

---

## Part F — Irreversibility

Classify these before deciding what gates each needs:

| Action | Reversible? | Gate |
|---|---|---|
| Open a PR | yes | none |
| Merge to `main` | yes (revert) | checks + PR |
| Deploy to `test` | yes (redeploy) | branch policy |
| Deploy to `prod` | mostly | approval + wait timer |
| `az stack sub create` with `--action-on-unmanage deleteAll` | **no** | `ALLOW_REAL_DEPLOY` + approval + what-if |
| Delete a resource group | **no** | the above, plus the lock |

The last two are why `deploymentFlags` and array-entry removal are called out in the PR template
and in every instruction file. They look like ordinary edits in a diff and they are not.

---

## What the exam asks

- **Environment protection rules on private repos require Enterprise.** On Free/Pro/Team they
  are public-repo only. This is a favourite question.
- **Environment variables and gates are coupled.** A job reading `vars.X` must declare
  `environment:` and inherits its gate — the reason `-preview` environments exist here.
- **`CODEOWNERS` requests review; a ruleset blocks.** Two separate mechanisms.
- **The cloud agent cannot** merge, approve, mark a draft ready, or run Git commands directly.
  It is limited to one branch (a PR branch or a new `copilot/*`). Its PRs need a human to
  approve running workflows. The requester cannot approve the resulting PR.
- **Agentic workflows are read-only by default**; every write is a declared `safe-output`.
- **Least privilege is per job, not per workflow.** Widening at the top grants it everywhere.
- **Prompt injection** is mitigated by stripping hidden characters from input, by the firewall,
  and — most durably — by not granting the capability in the first place.
- **Velocity matters and is examined.** "Add an approval everywhere" is the wrong answer. The
  right one gates irreversible and compliance-sensitive actions, and leaves reversible ones
  alone.
