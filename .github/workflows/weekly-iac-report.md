---
# A reporter. Reads the repository's own operational signals and writes one issue.
#
# The interesting property is that it is read-only over everything it inspects. It cannot fix
# what it finds, which keeps the report honest — a reporter that can act starts reporting the
# things it can act on.
#
# Docs for every field below: https://github.github.com/gh-aw/reference/frontmatter/

# WHEN it runs. Weekly, plus manual from the Actions tab or `gh aw run`.
#
# `weekly on monday` is gh-aw's friendly form; it compiles to a real cron with a scattered
# minute so every repository using it does not fire at the same instant.
#
# Weekly rather than daily on purpose. A run costs ~25 AI credits, so daily is ~750/month
# against a capped allowance — and a report nobody reads on a quiet day trains you to ignore
# the one that matters. Trigger syntax: https://github.github.com/gh-aw/reference/triggers/
on:
  schedule: weekly on monday
  workflow_dispatch:

# WHAT IT MAY READ. Everything here is `read` — this workflow inspects, it never changes.
# Writes are declared separately under `safe-outputs` below.
# https://github.github.com/gh-aw/reference/permissions/
permissions:
  contents: read
  issues: read
  pull-requests: read
  actions: read
  security-events: read

# WHICH AI runs it. `copilot` is the default; `claude`, `codex` and `gemini` also exist and
# need their own API-key secret. https://github.github.com/gh-aw/reference/engines/
engine: copilot

# NETWORK access for the agent. `defaults` = a curated allowlist, not the open internet.
# https://github.github.com/gh-aw/reference/network/
network: defaults

# WHICH GITHUB TOOLS the agent gets. `default` is the broad set; this workflow genuinely reads
# issues, pull requests, runs and alerts, so it keeps it.
# https://github.github.com/gh-aw/reference/tools/
tools:
  github:
    # NOT `default`. The first real run failed to check workflow runs, code scanning alerts
    # and deployment status, and said so in its own report — the `default` toolset covers
    # issues, pull requests, commits, releases and contents, and nothing else.
    #
    # Permissions and toolsets are two separate grants. `actions: read` and
    # `security-events: read` were already set below; without the matching toolsets the agent
    # had the right to read those things and no tool with which to do it.
    toolsets: [context, repos, issues, pull_requests, actions, code_security]

# WHAT IT MAY WRITE — and this is the entire list. An agentic workflow is read-only unless a
# capability appears here, so this workflow can open one issue and do nothing else. No prompt,
# and no prompt injection, can extend it.
# https://github.github.com/gh-aw/reference/safe-outputs/
safe-outputs:
  create-issue:
    max: 1
---

# Weekly IaC status report

Summarise the state of this infrastructure-as-code repository over the last 7 days and open
one issue with the result.

## What to gather

1. **Pull requests** — opened, merged, closed. For open ones: how long they have been open,
   and whether their required checks (`lint`, `psrule`, `version-sync`) are passing.
2. **Failing workflow runs** — any run of `PR Validation`, `Deploy` or `Copilot Setup Steps`
   that failed. For each, the job that failed and the error, not just the run URL.
3. **Code scanning** — open PSRule findings, by severity. Note anything that appeared in the
   last week.
4. **Deployments** — any run of `Deploy`, which environment, whether it is still waiting for
   an approver. A deployment sitting unapproved for a long time is worth surfacing.

## What to write

Lead with what needs a human. If nothing does, say that in the first line and keep the rest
short — a weekly report that opens with three paragraphs of throat-clearing gets filtered.

```markdown
## IaC status — week of <date>

<one line: what needs attention, or "nothing needs attention">

### Needs a human
- <item> — <why, and what the next step is>

### Activity
- Pull requests: <n> opened, <n> merged, <n> open
- Workflow failures: <n>
- Open PSRule findings: <n> (<n> new)
- Deployments: <n> (<n> awaiting approval)

### Detail
<only what is not obvious from the counts>
```

## Rules

- **Do not open an issue with nothing in it.** If there was no activity and nothing is failing,
  say exactly that in a two-line issue. Do not pad.
- **Report what you could not check.** If an API call failed or a permission was missing, say
  so — a section silently missing from a recurring report is how a monitoring gap survives.
- **Do not recommend fixes you cannot justify.** You are read-only over this repository by
  design; a recommendation you would have to inspect code to support is one you should not
  make. Point at the failing run and let a human open it.
- **Do not editorialise about trends** from a single week of data.
