---
# A scheduled reporter. Reads the repository's own operational signals and writes one issue.
#
# The interesting property is that it is read-only over everything it inspects. It cannot fix
# what it finds, which keeps the report honest — a reporter that can act starts reporting the
# things it can act on.
on:
  schedule: daily

permissions:
  contents: read
  issues: read
  pull-requests: read
  actions: read
  security-events: read

engine: copilot

network: defaults

tools:
  github:
    toolsets: [default]

safe-outputs:
  create-issue:
    max: 1
---

# Daily IaC status report

Summarise the state of this infrastructure-as-code repository over the last 24 hours and open
one issue with the result.

## What to gather

1. **Pull requests** — opened, merged, closed. For open ones: how long they have been open,
   and whether their required checks (`lint`, `psrule`, `version-sync`) are passing.
2. **Failing workflow runs** — any run of `PR Validation`, `Deploy` or `Copilot Setup Steps`
   that failed. For each, the job that failed and the error, not just the run URL.
3. **Code scanning** — open PSRule findings, by severity. Note anything that appeared in the
   last day.
4. **Deployments** — any run of `Deploy`, which environment, whether it is still waiting for
   an approver. A deployment sitting unapproved for a long time is worth surfacing.

## What to write

Lead with what needs a human. If nothing does, say that in the first line and keep the rest
short — a daily report that opens with three paragraphs of throat-clearing gets filtered.

```markdown
## IaC status — <date>

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
- **Do not editorialise about trends** from a single day of data.
