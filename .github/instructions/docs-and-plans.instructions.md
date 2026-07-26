---
applyTo: "docs/**"
description: "How to write plan artefacts and lab documentation."
---

# Documentation and plan artefacts

## `docs/plans/` — plan artefacts

A plan file is written **before** implementation and committed. It is durable state: if a
session is interrupted, the next one reads the plan rather than re-deriving it — and reaches
the same conclusions instead of new ones.

One file per piece of work, named `<short-slug>.md`:

```markdown
# <What this changes>

## Goal
One paragraph. What will be true afterwards that is not true now.

## Files
Every file to be added, changed or deleted, with a phrase each.

## Approach
The steps, in order. Enough that someone else could execute it.

## Risks
What could go wrong, and what would tell you it did. "Nothing" is not an answer —
if you genuinely believe there is no risk, say why.

## Status
not started | approved | in progress | landed in #<pr> | abandoned (<reason>)
```

Rules:

- Write the plan, then **stop** and wait for agreement. Do not write code and a plan in the
  same turn.
- If implementation shows the plan was wrong, **update the plan file** and say so. Silently
  diverging destroys the only thing the artefact is good for.
- Keep the `Status` line current. An abandoned plan stays, with its reason — knowing what was
  tried and rejected is worth more than a tidy directory.
- Never delete a plan file to make history look cleaner.

## `docs/labs/` — lab documentation

Each lab is one GH-600 domain. Structure:

```markdown
# Lab N — <domain name>

**Domain N: <exact title from the exam objectives> (<weight>)**

## What you are practising
The objective bullets this exercises, quoted from the study guide.

## Setup
Anything that must exist first.

## Steps
Numbered, concrete, copy-pasteable.

## Verify
How you know it worked — a command with expected output, or a specific thing to look at
in the UI. Never "confirm it looks right".

## What the exam asks
The distinctions and constraints that show up as questions, stated plainly.
```

A lab must be runnable by someone who has forgotten the context. Assume nothing.

## Writing style

- English, plain, present tense.
- Concrete over abstract: name the file, quote the command, show the output.
- State constraints as constraints. "Environment protection rules require a public repo on
  Free/Pro/Team" is useful; "may have limitations depending on your plan" is not.
- Explain **why** wherever the reason is not self-evident. A rule without a reason gets deleted
  by the next person who finds it inconvenient.
- Keep tables narrow enough to read in a terminal without wrapping.
