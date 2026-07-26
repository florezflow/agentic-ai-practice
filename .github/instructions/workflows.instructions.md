---
applyTo: ".github/workflows/**"
description: "Rules for CI/CD workflows — the files that define the guardrails."
---

# Workflows

These files *are* the guardrails. Editing one is editing the thing that constrains agents,
including whichever agent is reading this. Every change here must be called out explicitly in
your response and in the pull request description, even when it is obviously correct.

## Permissions

- Set `permissions:` at the top of every workflow, as narrow as the workflow can function with.
  `contents: read` is the default posture.
- Widen at the **job** level, never at the top level, and only for the job that needs it. The
  `psrule` job takes `security-events: write` for itself; no other job in that file has it.
- `id-token: write` is required for OIDC login and appears only in the deploy jobs.
- Never add `pull_request_target`. It runs with a writable token in the context of the base
  repository while checking out untrusted head code. There is no use for it here.

## Pinning

- The Bicep CLI version is pinned in one `env: BICEP_VERSION` per workflow. Bump it there and
  nowhere else.
- Actions are referenced by major tag (`actions/checkout@v5`). If a workflow ever handles
  secrets that matter, move to full SHA pinning.

## Checks must be able to fail

A check that cannot fail is worse than no check, because it reads as green.

- If a step iterates over files, it must **fail when it finds none**. A glob that silently
  matches zero files is the most common way a suite quietly stops testing anything. The `lint`
  job does this explicitly.
- If a step both produces evidence and enforces a gate, the evidence must survive the failure.
  The `psrule` job uses `continue-on-error` on the analysis, uploads the SARIF, then re-applies
  the gate in a separate step — otherwise a failing run hides the findings that explain it.
- Do not add `continue-on-error` to make a job green. Use it only to sequence a
  produce-then-enforce pair, as above.

## Shell

- The default shell is `bash -e {0}`. A command whose exit status you need to inspect must use
  `|| status=$?`, or the step aborts before you can act on it.
- Never interpolate `${{ inputs.* }}` or `${{ github.event.* }}` directly into a shell command.
  Pass them through `env:` and reference the environment variable. Workflow inputs here are
  `choice` types so the risk is bounded, but the habit is what matters.
- Prefer `case` over `[[ ]]` for glob matching, so the script does not depend on the shell.

## Environments and gates

- `environment:` on a job is what creates an approval gate. Nothing in the YAML expresses the
  reviewers, the wait timer or the branch policy — those live in repository settings, and the
  YAML only names the environment.
- Environment variables and environment protection rules are scoped to the same environment.
  A job that reads `vars.X` must declare `environment:` and inherits its gate. That is why
  ungated `-preview` environments exist for the what-if job; see the comment in `deploy.yml`.
- Deploy workflows are `workflow_dispatch` only. Infrastructure does not deploy because a
  branch moved.

## Concurrency

- PR validation cancels in-progress runs of itself (`cancel-in-progress: true`).
- Deploys never cancel in-progress runs (`cancel-in-progress: false`). Cancelling a run that is
  waiting for an approver destroys the approval record.

## Do not

| Do not | Why |
|---|---|
| Disable, skip or `if: false` a required check | The check is the point |
| Add a rule exclusion to make a job pass | Fix the finding or argue it in the PR |
| Add a step that mutates Azure | The repo is what-if/validate only |
| Set `ALLOW_REAL_DEPLOY` | Human decision, taken deliberately |
| Grant `write` where `read` works | Least privilege is the default, not the exception |
