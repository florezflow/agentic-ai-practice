# Lab 2 — Tool use and environment interaction

**Domain 2: Implement tool use and environment interaction (20–25%)** — the largest domain.

## What you are practising

- Identify required tools; configure agent tools; configure agent tool permissions
- Add an MCP server as a tool to an agent; configure a GitHub remote MCP server
- Configure MCP allow lists
- Evaluate the execution context for an agent
- Configure an agent to be invoked in a CI workflow
- Implement traceability and accountability for agent actions

---

## Part A — The same task under four tool postures

The four agents in `.github/agents/` differ in `tools:` and almost nothing else that matters.
Give them all the same task and watch the behaviour fall out of the capability, not the prompt.

Task: *"Check whether `modules/resources/locks/main.bicep` uses a current API version."*

| Agent | `tools:` | Expected behaviour |
|---|---|---|
| `bicep-planner` | `read`, `search`, `edit` | Reads the file, states the API version, **cannot verify** whether it is current |
| `bicep-builder` | full | Reads it, runs `bicep build`, reports the linter's opinion |
| `whatif-analyzer` | `read`, `search` | Reads it, but says this is outside its job |
| `docs-researcher` | `microsoft-learn/*` | **Cannot open the file.** Can say what the current version is, from the docs |

### Verify

Run the task against `bicep-planner` and `docs-researcher` and compare.

The interesting result is `docs-researcher`: it must say it cannot see files. If it describes
the contents of `main.bicep`, it hallucinated — it has no `read` tool. That is a concrete,
checkable demonstration of why tool scoping is a correctness mechanism and not only a
security one.

Neither agent alone can answer the question. `bicep-planner` knows what the file says;
`docs-researcher` knows what current means. That is the handoff Lab 5 builds on.

---

## Part B — Remove a tool and observe

1. Edit `.github/agents/bicep-planner.agent.md`:

   ```yaml
   tools: ["read", "search"]     # was: ["read", "search", "edit"]
   ```

2. Re-run a planning task from Lab 1.

### Verify

The agent can no longer write `docs/plans/<slug>.md`. It should say so. Whatever it produces
instead — a plan in a comment, a plan in its response — is *not* an inspectable artefact in
standard tooling, which is precisely what Domain 1 asks for.

Restore `edit` afterwards. Note in your own words what was lost: the plan still existed, but it
stopped being reviewable, diffable and resumable.

---

## Part C — MCP: in-profile versus repository settings

`docs-researcher.agent.md` declares its MCP server in the profile:

```yaml
tools: ["microsoft-learn/*"]
mcp-servers:
  microsoft-learn:
    type: 'http'
    url: 'https://learn.microsoft.com/api/mcp'
    tools: ["*"]
```

Now add the same server the other way: **Settings → Copilot → MCP servers**, paste:

```json
{
  "mcpServers": {
    "microsoft-learn": {
      "type": "http",
      "url": "https://learn.microsoft.com/api/mcp",
      "tools": ["*"]
    }
  }
}
```

### Verify

```bash
git log --oneline -5 -- .github/agents/
```

The in-profile version appears in git history. The repository-settings version appears
**nowhere in the repository** — no commit, no diff, no review.

Both give an agent the same tool. Only one of them is something a reviewer can see happening.
That is why `CODEOWNERS` covers `.github/agents/`, and why this repo declares MCP servers in
profiles.

Remove the repository-settings copy when you are done.

---

## Part D — The firewall, and the two things it does not cover

1. Ask the cloud agent to fetch something outside the allowlist:

   > Fetch `https://example.com/some-schema.json` and tell me what is in it.

2. Look at the resulting PR.

### Verify

A blocked request adds a warning to the PR body (new PRs) or a comment (existing ones), naming
the blocked address and the command that tried to reach it.

Now the part that matters more:

- `.mcp.json` and `docs-researcher` both reach `learn.microsoft.com`, and the firewall never
  sees it. **MCP servers are outside the firewall.**
- `copilot-setup-steps.yml` downloads the Bicep CLI from `github.com` and installs a
  PowerShell module from the PSGallery. **Setup steps are outside the firewall too.**

So the boundary of what the agent can reach is not the allowlist. It is the union of the
allowlist, every MCP server you configured, and everything your setup steps install. Adding an
MCP server is widening network access — treat it that way.

---

## Part E — Execution context, and the failure that hides

`.github/workflows/copilot-setup-steps.yml` installs the pinned Bicep CLI and PSRule, then runs
this repo's own checks.

Break it on purpose:

1. Change the pin in `copilot-setup-steps.yml` to a version that does not exist,
   e.g. `v0.99.99`.
2. Push. The workflow runs on changes to its own path.

### Verify

```bash
gh run list --workflow=copilot-setup-steps.yml --limit 1
```

It fails at the install step. Now try the more instructive variant: rename the job from
`copilot-setup-steps` to `setup`.

The workflow still runs — and the agent silently gets a bare environment, because GitHub
ignores a differently-named job with **no error anywhere**. That is the failure mode to
remember: not a broken setup, but an ignored one.

Restore both.

---

## Part F — Agents in CI

`.github/workflows/bicep-pr-reviewer.md` is an agent invoked by a workflow trigger rather than
by a person.

### Verify

Open any PR touching a `.bicep` file. Without `COPILOT_GITHUB_TOKEN` set, the run fails fast:

```
Error: None of the following secrets are set: COPILOT_GITHUB_TOKEN
The GitHub Copilot CLI engine requires either COPILOT_GITHUB_TOKEN secret to be configured.
```

The `agent` and `safe_outputs` jobs **skip** — the activation guard runs before anything else
and stops the workflow rather than letting it half-run. Confirm with:

```bash
gh run view <run-id>
```

Set the secret to make it work:

```bash
gh secret set COPILOT_GITHUB_TOKEN --repo mflorez-bag/agentic-ai-practice
```

---

## What the exam asks

- **`tools:` accepts** aliases (`read`, `edit`, `search`, `execute`, `web`, `agent`, `todo`),
  exact names, `"server/tool"`, `"server/*"`, `["*"]` for all, `[]` for none. **Omitting the
  property means everything** — a blank `tools:` is not a safe default.
- **Two built-in MCP servers** need no configuration: `github` (read-only, scoped to the source
  repository) and `playwright` (localhost only).
- **The firewall covers only Bash-tool processes.** Not MCP servers, not setup steps. This is
  the single most-tested detail in this domain.
- **`copilot-setup-steps.yml`**: job must be named `copilot-setup-steps`; only `steps`,
  `permissions`, `runs-on`, `services`, `snapshot`, `timeout-minutes` (max 59) are honoured;
  must be on the default branch. Its `permissions:` do **not** affect the agent's own token.
- **MCP env-var syntax**: `$VAR`, `${VAR}`, `${VAR:-default}`, and — in custom agents only —
  `${{ secrets.COPILOT_MCP_* }}` and `${{ vars.COPILOT_MCP_* }}`.
- **The coding agent's MCP config is separate** from Claude Code's `.mcp.json`. Repo admin
  only, entered as JSON in repository settings, supports MCP **tools** but not resources or
  prompts, and does not support OAuth remote servers.
- **Traceability**: agent commits are cryptographically signed, co-authored by the requester,
  and link to the session log. The requester cannot approve the resulting PR.
