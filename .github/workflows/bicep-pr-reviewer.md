---
# Reviews changed Bicep against this repo's own written standards, and says so in a comment.
#
# It cannot change code, cannot approve, cannot merge. Its only write capability is
# `add-comment`, declared below. Everything else it might want to do is simply absent —
# not blocked by a rule it could be argued out of.
#
# Docs for every field below: https://github.github.com/gh-aw/reference/frontmatter/

# WHEN it runs. Fires on every push to an open pull request.
# https://github.github.com/gh-aw/reference/triggers/
on:
  pull_request:
    types: [opened, synchronize, reopened]

# WHAT IT MAY READ. Both `read` — a reviewer that could write to the repo is not a reviewer.
# https://github.github.com/gh-aw/reference/permissions/
permissions:
  contents: read
  pull-requests: read

# WHICH AI runs it. https://github.github.com/gh-aw/reference/engines/
engine: copilot

# NETWORK access: a curated allowlist, not the open internet.
# https://github.github.com/gh-aw/reference/network/
network: defaults

# WHICH GITHUB TOOLS the agent gets. https://github.github.com/gh-aw/reference/tools/
tools:
  github:
    # Not `default` — that pulls in the issues toolset, which would need `issues: read` for
    # capability this workflow never uses. Toolsets and permissions are coupled: the honest
    # fix for a permissions warning is usually to want less, not to grant more.
    toolsets: [context, repos, pull_requests]

# WHAT IT MAY WRITE — the entire list. One comment, nothing else.
# https://github.github.com/gh-aw/reference/safe-outputs/
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

If you found nothing, say so in one line. A short comment that a reviewer trusts is worth more
than a long one they learn to scroll past.

## Always post the comment

**Use `add-comment` on every run, including when you have no findings.** Do not use the `noop`
safe output. "No findings" is a result, and a reviewer needs to see that the review ran and
concluded — silence is indistinguishable from the workflow being broken.

`noop` is only correct if the pull request changes no `.bicep` or `.bicepparam` files at all.

(This instruction exists because the first real run of this workflow produced a perfectly good
review and then emitted it as `noop`, so nothing was posted. The earlier wording said "say so
in one line and stop", and the agent read "stop" as "stay silent". Worth remembering: an
instruction that is clear to a human can still route an agent to the wrong tool.)
