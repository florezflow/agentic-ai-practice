---
name: validate
description: Run every check CI runs — bicep build, bicep build-params, version-sync — and report what failed. Use before opening a pull request, or when a PR check is red and you need to reproduce it locally.
---

# validate

Reproduces the three required status checks locally, so a red PR is never a surprise.

## Steps

1. **Build every template.**

   ```bash
   for t in $(find modules -name 'main.bicep' -type f; find patterns -maxdepth 2 -name '*.bicep' -type f); do
     echo "--- $t"
     bicep build "$t" --stdout > /dev/null || echo "FAILED: $t"
   done
   ```

2. **Build every parameter file.**

   ```bash
   for p in $(find patterns -name '*.bicepparam' -type f); do
     echo "--- $p"
     bicep build-params "$p" --stdout > /dev/null || echo "FAILED: $p"
   done
   ```

3. **Check version synchronisation.**

   ```bash
   bash .github/scripts/validate-version-sync.sh
   ```

4. **PSRule** (optional locally; it runs in CI on every PR). Requires PowerShell and the
   `PSRule.Rules.Azure` module:

   ```bash
   pwsh -c "Invoke-PSRule -InputPath . -Module PSRule.Rules.Azure -Format File"
   ```

## Reporting

Report exactly what ran and what did not. If PowerShell is unavailable, say PSRule was not
run — do not imply it passed.

For each failure, give the file, the message, and what would fix it. Do not fix anything in
this skill; validation and repair are separate steps, and the human decides which failures are
worth fixing now.

## Do not

- Do not lower a linter level in `bicepconfig.json` or add an exclusion to `ps-rule.yaml` to
  make something pass. That is a change to the gate itself and is on the "flag it" list in
  `AGENTS.md`.
- Do not report a check as passing that you did not execute.
