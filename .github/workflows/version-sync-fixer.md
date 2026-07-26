---
# Fixes version drift — but only ever by opening a pull request.
#
# This is the one workflow here that changes code, so it is the one worth reading closely.
# It has no push access. Its only write capability is `create-pull-request`, which means its
# output lands in exactly the same place a human's does: a branch, a pull request, the three
# required checks, and a review. An agent that could push would bypass all four.
#
# Triggered by a label rather than by the failure itself, so a human decides when it runs.
on:
  issues:
    types: [labeled]

permissions:
  contents: read
  issues: read

engine: copilot

network: defaults

tools:
  github:
    # It reads one issue and some files. It does not read pull requests, so it does not get
    # the toolset that would require `pull-requests: read`.
    toolsets: [context, repos, issues]

safe-outputs:
  create-pull-request:
    max: 1
  add-comment:
    max: 1
---

# Version sync fixer

Only act if the label just applied is **`fix-version-sync`**. If it is any other label, do
nothing and produce no output at all.

## The problem you are fixing

Every component in this repository declares its version in three places, and
`.github/scripts/validate-version-sync.sh` fails the build when they disagree:

```
metadata.json      { "version": { "major": 1, "minor": 0, "patch": 0 } }
<template>.bicep   metadata version = '1.0.0'
CHANGELOG.md       ## 1.0.0 - DD.MM.YYYY
```

Drift is almost always someone bumping one and forgetting the others.

## What to do

1. Read the issue. It should name the component, or link a failing run. If it names neither,
   comment saying what you need and stop — do not guess which component was meant.

2. Determine the intended version. **`metadata.json` is the source of truth**, unless the issue
   explicitly says otherwise. Do not infer intent from whichever file happens to have the
   highest number.

3. Bring the other two into line:
   - Set `metadata version = 'X.Y.Z'` in the component's template.
   - Add a `## X.Y.Z - DD.MM.YYYY` heading to `CHANGELOG.md`, at the top of the entry list,
     using today's date.

4. For the changelog body, **describe what actually changed** — read the git history for that
   component since the previous version. If you cannot tell, write
   `- <version bump; see #<issue> — description pending>` and say in the pull request
   description that the entry needs a human. Do not invent a plausible-sounding change.

5. Open the pull request:
   - Branch: `fix/version-sync-<component>`
   - Title: `fix: sync <component> version to X.Y.Z`
   - Body: what drifted, what you changed, which file you treated as the source of truth, and
     anything you could not determine.

## Boundaries

- **Only the three version locations.** Do not fix a linter warning, tidy formatting, or
  "improve" anything you pass on the way. A pull request that does more than its title says is
  the reason agent PRs get distrusted.
- **Never touch** `.github/workflows/`, `.github/agents/`, `.github/instructions/`,
  `AGENTS.md`, `CODEOWNERS`, `bicepconfig.json` or `ps-rule.yaml`. If the fix appears to
  require it, it is not this workflow's job — comment and stop.
- **Never change `.bicepparam` files.** Nothing about version drift needs them, and they are
  the highest blast radius files in the repo.
- **If more than one component has drifted, fix one** — the one the issue names — and say in
  the pull request that others remain. One reviewable change beats one large one.
- **Your pull request is not special.** It faces `lint`, `psrule` and `version-sync` like any
  other, cannot approve itself, and cannot merge itself. If a check fails, that is the answer.
