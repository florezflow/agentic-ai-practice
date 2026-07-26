# Lab 4 — Evaluation, error analysis and tuning

**Domain 4: Perform evaluation, error analysis, and tuning (15–20%)**

## What you are practising

- Specify expected outcomes and operational constraints for agent tasks
- Identify qualitative and quantitative evaluation signals
- **Generate evaluation signals by using automated scanning tools**
- Identify failures using logs, plans, traces, outputs, and workflow artifacts
- Classify root causes: reasoning errors, tool misuse, context or environment issues
- Tune agent behaviour: revise instructions, refine memory usage, refine tool access

---

## The signals this repo produces

| Signal | Kind | Where |
|---|---|---|
| `lint` | binary | Actions log |
| `psrule` | graded findings | **Security tab**, category `psrule-azure` |
| `version-sync` | binary, with per-file annotations | Actions log + inline on the diff |
| what-if | structured change list | run artefact `what-if-<n>` |
| PR review comments | qualitative | the PR |
| Plan-vs-diff | qualitative | the PR template checkbox |

The one worth dwelling on is `psrule`, because it is the only *graded, machine-readable,
historical* signal — the others are pass/fail or prose.

---

## Part A — Make a finding appear

1. Add a rule violation deliberately. In
   `patterns/0001-resource-groups/configurations/test/rg_0001-resource-groups_test.bicepparam`,
   empty out a required tag:

   ```bicep
   tags: {
     CostCenter: ''
     Creator: ''
     CreationDate: ''
     Description: ''
     IaC: ''
   }
   ```

2. Open a PR.

### Verify

```bash
gh pr checks <n>
```

Then open **Security → Code scanning**, filter to `psrule-azure`, and read the finding: rule
ID, severity, the file and line, and the documentation link.

Note what that gives you which a log line does not: it persists after the run expires, it
deduplicates across runs, it tracks open/fixed state, and it is queryable. That is the
difference between a check and an evaluation signal.

---

## Part B — Findings survive a failing run

Look at the `psrule` job in `.github/workflows/pr-validate.yml`. The analysis step has
`continue-on-error: true`, the SARIF upload runs `if: always()`, and a **separate** step
re-applies the gate.

Break it on purpose to see why. Remove the `continue-on-error` line, push, and look at the
Security tab.

### Verify

Without it, a failing analysis aborts the job before the upload — so the findings that explain
the failure never reach the Security tab. You get a red check and no information.

Restore it. This produce-then-enforce ordering is the general shape: **evidence must survive
the failure it explains.** A gate that destroys its own diagnostics teaches people to rerun
rather than read.

---

## Part C — Classify a failure

Introduce three different failures, one at a time, and classify each before fixing it:

| Injected failure | Symptom | Root cause class |
|---|---|---|
| Change `metadata version` without `metadata.json` | `version-sync` fails with two annotations | **Reasoning** — the agent knew the rule and skipped a step |
| Point `deploy.yml`'s Bicep pin at `v0.99.99` | install step 404s | **Environment** |
| Give `bicep-planner` a task needing `bicep build` | it plans without verifying | **Tool access** — the capability is absent by design |

For each, find the evidence before forming an opinion:

```bash
gh run view <run-id> --log | grep -iE 'error|failed'
gh run download <run-id>            # what-if artefacts
gh aw logs <workflow-name>          # agentic workflow runs
gh aw audit <run-id>                # detailed agentic run trace
```

The classification is the point. All three look like "the agent got it wrong", and all three
need a different fix: a clearer instruction, an environment repair, or a capability change.
Reaching for a prompt tweak when the cause was environmental is the most common wasted loop.

---

## Part D — The tuning loop

Now do the loop end to end, on a real weakness.

1. **Observe.** Ask an agent to add a parameter to a module. Watch whether it bumps all three
   version locations unprompted.

2. **Measure.** If it did not, that is your baseline. Run it twice more to confirm it is a
   pattern and not a one-off.

3. **Tune.** Pick the narrowest change that could fix it:

   | Cause | Fix |
   |---|---|
   | The rule is not stated where the agent reads | add it to `bicep-standards.instructions.md` |
   | The rule is stated but buried | move it earlier, make it a checklist item |
   | The agent cannot check its own work | that is tool access, not instructions |
   | The rule is genuinely ambiguous | write a `.ps-rule/` rule so it fails loudly instead |

4. **Re-measure.** Same task, fresh session. Did the failure class disappear?

5. **Record.** Note what you changed and what happened. An untracked tuning loop converges on
   longer instructions rather than better ones.

### Verify

The failure class is gone across two fresh sessions, and no other behaviour regressed.

Watch for the trap: it is tempting to add a rule for every single mistake. Instructions that
grow monotonically stop being read. If a rule can be a check instead, make it a check — a
`.ps-rule/` rule or a script in `.github/scripts/` fails loudly and costs no context.

---

## Part E — Turn a convention into a signal

`.ps-rule/` is empty. Write one rule and close the loop from prose to automation.

Good candidates, all currently enforced only by `AGENTS.md`:

- Resource group names must match `<prefix>-<name>-<suffix>-rg`
- The `IaC` tag must contain `DeploymentStack:`
- Prod configurations must set `deploymentFlags.locks: true`

See <https://microsoft.github.io/PSRule/v2/authoring-rules/>.

### Verify

The rule fires on a deliberate violation, appears in the Security tab, and blocks the PR. You
have converted a rule that depended on someone remembering into one that fails on its own —
which is exactly what "align evaluation criteria with development intent" means in practice.

---

## What the exam asks

- **"Generate evaluation signals by using automated scanning tools"** is an explicit objective.
  The concrete answer is a scanner emitting SARIF into code scanning, where findings persist,
  deduplicate and track state.
- **Code scanning, secret scanning and push protection are free on public repositories**, on
  every plan. On private repos they need GitHub Code Security / Secret Protection, which
  personal accounts cannot buy.
- **Root-cause classes**: reasoning errors, tool misuse, context/environment issues. Questions
  give a symptom and ask for the class — practise the mapping, not just the fix.
- **Tuning has three levers**: instructions, memory, tool access. Choosing the wrong lever is
  the scenario the questions are built around.
- **The cloud agent scans its own output** with CodeQL, dependency review against the GitHub
  Advisory Database, and secret scanning — no Advanced Security licence required.
- Artefacts, logs, plans and traces are all named as failure-analysis inputs. Know which one
  answers which question: logs for *what* failed, traces for *where*, plans for *whether it was
  even the intent*.
