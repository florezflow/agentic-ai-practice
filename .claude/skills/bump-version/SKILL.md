---
name: bump-version
description: Bump a module or pattern version consistently across metadata.json, the template's metadata version line, and CHANGELOG.md. Use whenever a component's behaviour or parameter contract changes.
---

# bump-version

Three files declare a component's version and the `version-sync` check fails if they disagree.
This skill changes all three together, which is the only correct way to do it.

## Input

The component directory, e.g. `modules/resources/locks` or `patterns/0001-resource-groups`,
and the kind of bump.

## Choosing the bump

| Change | Bump |
|---|---|
| Parameter removed, renamed, or made required | major |
| Type narrowed, default changed in a way that alters behaviour | major |
| New optional parameter, new capability, new output | minor |
| Fix with no change to the parameter contract | patch |

When in doubt between minor and major, ask. A consumer discovering a breaking change at deploy
time is much worse than an over-cautious major.

## Steps

1. Read the current version from `<dir>/metadata.json`.
2. Compute the new version.
3. Update `<dir>/metadata.json`.
4. Update the `metadata version = 'X.Y.Z'` line in the component's template
   (`main.bicep` for modules, `<name>.bicep` for patterns).
5. Add a `CHANGELOG.md` entry at the **top** of the entry list, below the intro paragraph:

   ```markdown
   ## X.Y.Z - DD.MM.YYYY

   Features (INITIALS):

   - What changed, written for someone who has to decide whether to adopt it.
   ```

   Today's date in `DD.MM.YYYY`. Do not invent initials — ask, or use the git user.
6. Verify:

   ```bash
   bash .github/scripts/validate-version-sync.sh
   ```

## Writing the changelog entry

Write for a consumer deciding whether to take the change, not for a diff reader. "Added
`parLockLevel` so a lock can be `ReadOnly`" is useful. "Updated main.bicep" is not.

For a major bump, state what breaks and what the caller must do about it.

## Do not

- Do not bump only `metadata.json`. That is precisely the drift the check exists to catch.
- Do not edit an existing changelog entry to cover new work. Add a new one.
