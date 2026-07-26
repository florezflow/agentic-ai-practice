## What

<!-- What changes, in one or two sentences. -->

## Why

<!-- The problem this solves. If it came from a lab, say which one. -->

## Validation

<!-- Delete what does not apply. CI runs lint, psrule and version-sync; say what YOU ran. -->

- [ ] `bicep build` clean on every changed template
- [ ] `bicep build-params` clean on every changed configuration
- [ ] `what-if` reviewed for a changed configuration (attach or link the artefact)
- [ ] Version bumped in `metadata.json`, `metadata version` and `CHANGELOG.md` together

## Agent involvement

<!--
Accountability, not bureaucracy: a reviewer reads an agent-authored diff differently than a
hand-written one. Say which agent, and what you checked that the agent could not.
-->

- [ ] Written by hand
- [ ] Agent-assisted — agent: `________`
- [ ] Fully agent-authored — agent: `________`

If an agent was involved:

- [ ] The plan artefact under `docs/plans/` matches what actually landed
- [ ] I checked the parts the agent had no way to verify (intent, blast radius, naming fit)

## Blast radius

<!--
Anything that changes what gets deployed or deleted. Be specific — "flipped
deploymentFlags.locks to false" is the kind of one-line change that removes every lock in an
environment when deployed as a stack.
-->

- [ ] No change to any `deploymentFlags`
- [ ] No entries removed from `parResourceGroups`
- [ ] No change to `.github/workflows/`, `.github/agents/` or `AGENTS.md`
