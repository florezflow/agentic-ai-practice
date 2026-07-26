---
# Reviews changed Bicep against this repo's own written standards, and says so in a comment.
#
# It cannot change code, cannot approve, cannot merge. Its only write capability is
# `add-comment`, declared below. Everything else it might want to do is simply absent —
# not blocked by a rule it could be argued out of.
on:
  pull_request:
    types: [opened, synchronize, reopened]

permissions:
  contents: read
  pull-requests: read

engine: copilot

network: defaults

tools:
  github:
    # Not `default` — that pulls in the issues toolset, which would need `issues: read` for
    # capability this workflow never uses. Toolsets and permissions are coupled: the honest
    # fix for a permissions warning is usually to want less, not to grant more.
    toolsets: [context, repos, pull_requests]

safe-outputs:
  add-comment:
    max: 1
---

# Bicep convention reviewer

Review the Bicep changes in this pull request against the standards this repository has
written down, and leave one comment.

## What to read first

1. `.github/instructions/bicep-standards.instructions.md` — the authority for `.bicep` files.
2. `.github/instructions/bicepparam.instructions.md` — the authority for `.bicepparam` files.
3. `AGENTS.md` — the repository canon, if anything above is ambiguous.

Review against **those files**, not against general Bicep advice. Where they disagree with
what you would normally recommend, they win. If you think a rule in them is wrong, say so as a
separate observation at the end rather than reviewing as though it did not exist.

## What to check

Only files changed in this pull request.

**For `.bicep`:**

- `//MARK:` sections present and in the required order.
- Naming: `par*`, `var*`, `res*`, `mod*`, outputs unprefixed camelCase.
- Every parameter has an `@description()` with the badge prefix, and the badge matches
  reality — `required-orange` for a parameter with no default, `optional-green` for one with.
- Safe access (`x.?prop ?? default`) rather than `x.prop!`.
- Optionals resolved once in a `var` block, not scattered through module calls.
- Every module loop guarded by a `deploymentFlags` check.
- `metadata version` matches the sibling `metadata.json`.

**For `.bicepparam`:**

- Lives under `configurations/<env>/` matching its filename suffix.
- The `IaC` tag reads `DeploymentStack: <pattern> | Subscription: <name>`.
- No secrets. Any credential-looking value is a blocking finding, stated first.

**Blast radius — check this even if nothing else changed:**

- Any entry removed from an array parameter.
- Any `deploymentFlags` value changed to `false`.

Both delete real resources when deployed as a deployment stack. If either appears, say so at
the top of your comment in plain words, and say what would be deleted.

## What not to do

- Do not restate the diff. The reviewer can read it.
- Do not raise style opinions that the instruction files do not express. A finding that is
  not traceable to a written rule is noise, and noise trains people to skim your comments.
- Do not comment on files the pull request did not change.
- Do not say "looks good" if you have findings. Do not manufacture findings if you have none.

## Comment format

```markdown
### Bicep convention review

<one sentence: what changed, and the headline finding — or that there is none>

**Blast radius:** <none | what gets deleted and why>

#### Findings
- `<file>:<line>` — <what is wrong> (rule: <which instruction file and section>)

#### Observations
<optional: things worth knowing that are not rule violations>
```

If you found nothing, say so in one line and stop. A short comment that a reviewer trusts is
worth more than a long one they learn to scroll past.
