# Patterns

A pattern composes modules into something deployable. It owns everything the modules
deliberately do not: name composition, tag inheritance, scope resolution, deployment flags,
and the parameter contract that a human actually fills in.

Patterns are numbered so they sort and so the number can be referenced in stack names,
tags and pipeline inputs:

```
patterns/NNNN-<kebab-case-name>/
├── <name>.bicep                    # main template, targetScope = 'subscription'
├── metadata.json
├── CHANGELOG.md
├── artifacts/
│   └── types.bicep                 # @export()ed type definitions
├── configurations/
│   ├── test/<name>_test.bicepparam
│   └── prod/<name>_prod.bicepparam
└── docs/
    └── deployment-notes.md
```

Note the main template drops the number: `0001-resource-groups/resource-groups.bicep`.

## Conventions

- `targetScope = 'subscription'` — resource groups are created by the pattern, so it cannot
  target a resource group.
- Types live in `artifacts/types.bicep` and are imported, never redefined inline.
- Every optional property is resolved exactly once in a `var` block, so the module loops read
  cleanly and there is one place to look for defaults.
- Every module loop is guarded by a `deploymentFlags` check.
- `metadata version`, `metadata.json` and the newest `CHANGELOG.md` heading must agree.

## Patterns in this repo

| Pattern | Version | What it does |
|---|---|---|
| [`0001-resource-groups`](0001-resource-groups/) | 1.0.0 | Creates a list of resource groups with optional management locks |
