# MCP servers, the agent firewall, and setup steps

What the Copilot cloud agent can reach, how that is configured, and which parts of it live
outside git.

---

## The three places tools come from

| Where | Configured in | Visible in a diff? | Scope |
|---|---|---|---|
| Agent profile `mcp-servers:` | `.github/agents/*.agent.md` | **yes** | that one agent |
| Repository MCP configuration | GitHub web UI → Settings → Copilot → MCP servers | **no** | every agent in the repo |
| Built-in servers | nothing | n/a | `github` (read-only, scoped to this repo), `playwright` (localhost only) |

Prefer the agent profile. A tool an agent gained through a JSON blob in the web UI is a
capability change nobody reviewed — the same change made in `.github/agents/` shows up in a
pull request, and `CODEOWNERS` covers that directory for exactly this reason.

`docs-researcher.agent.md` demonstrates the in-git form:

```yaml
tools: ["microsoft-learn/*"]
mcp-servers:
  microsoft-learn:
    type: 'http'
    url: 'https://learn.microsoft.com/api/mcp'
    tools: ["*"]
```

### Repository-level configuration (for reference)

If you want a server available to every agent, Settings → Copilot → MCP servers takes JSON.
Repository admin only. Secrets are referenced as `COPILOT_MCP_*` Actions secrets:

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

Environment variable syntax supported in MCP blocks:

```
$COPILOT_MCP_VALUE
${COPILOT_MCP_VALUE}
${COPILOT_MCP_VALUE:-default}
${{ secrets.COPILOT_MCP_VALUE }}     custom agents only
${{ vars.COPILOT_MCP_VALUE }}        custom agents only
```

### Tool names and aliases

`tools:` takes aliases, individual tool names, or MCP-qualified names:

| Alias | Covers | Cloud agent equivalent |
|---|---|---|
| `execute` | shell, Bash, powershell | `bash` / `powershell` |
| `read` | Read, NotebookRead | `view` |
| `edit` | Edit, MultiEdit, Write | `str_replace` |
| `search` | Grep, Glob | `search` |
| `agent` | invoke other custom agents | custom agent tools |
| `web` | WebSearch, WebFetch | not available in cloud |

```yaml
tools: ["*"]                    # everything (same as omitting the property)
tools: ["read", "search"]       # a subset
tools: ["some-mcp/some-tool"]   # one tool from an MCP server
tools: ["some-mcp/*"]           # every tool from an MCP server
tools: []                       # nothing
```

The agents in this repo use four different postures on purpose — see the table in
[`docs/gh600-domain-map.md`](gh600-domain-map.md).

---

## The firewall

The cloud agent runs behind a firewall with a recommended allowlist enabled by default, so it
can fetch dependencies but not reach arbitrary hosts. When a request is blocked, a warning is
added to the pull request body (new PRs) or as a comment (existing ones), naming the blocked
address and the command that tried to reach it.

**The limit that catches people out:** the firewall applies only to processes the agent starts
through its Bash tool. It does **not** apply to MCP servers, and it does **not** apply to
processes started in `copilot-setup-steps.yml`. Those two are outside it entirely.

So the firewall is not the boundary of what the agent can reach — the union of the firewall,
the MCP servers you configured, and your setup steps is. Treat adding an MCP server as widening
network access, because it is.

Configured at: Settings → Copilot → coding agent → firewall. You can extend the allowlist or
disable it; disabling it on a repository that agents write to is not a decision to make quietly.

---

## `copilot-setup-steps.yml`

[`.github/workflows/copilot-setup-steps.yml`](../.github/workflows/copilot-setup-steps.yml)
installs the Bicep CLI and PSRule so the agent can run this repo's own checks before opening a
pull request.

Constraints, all of which are silent failures if you get them wrong:

- The job **must** be named `copilot-setup-steps`. A differently-named job is ignored, with no
  error — the agent simply starts in a bare environment.
- Only `steps`, `permissions`, `runs-on`, `services`, `snapshot` and `timeout-minutes`
  (max 59) are honoured. Everything else set on the job is discarded.
- The file must be on the **default branch** to take effect.
- `permissions:` here applies to the setup steps, **not** to the token the agent itself
  receives.

The last step deliberately runs `bicep build` and `validate-version-sync.sh`. If the agent's
environment cannot reproduce CI, that is worse than having no setup steps at all — the agent
will report that it validated, and be wrong.

The Bicep version is pinned in both this file and `pr-validate.yml`. Keep them equal. An agent
validating with a different compiler than CI will confidently hand you work that fails.

---

## Claude Code: `.mcp.json`

Project-scope MCP configuration, committed:

```json
{
  "mcpServers": {
    "bicep":           { "type": "stdio", "command": "dnx", "args": ["-y", "Azure.Bicep.McpServer"] },
    "microsoft-learn": { "type": "http",  "url": "https://learn.microsoft.com/api/mcp" },
    "github":          { "type": "http",  "url": "https://api.githubcopilot.com/mcp",
                         "headers": { "Authorization": "Bearer ${GITHUB_PAT}" } }
  }
}
```

`${GITHUB_PAT}` is expanded from the environment, so the file carries no secret and is safe in
a public repository. Export it in your shell; do not put it here.

This is a **different configuration surface** from the Copilot cloud agent's. The two do not
read each other. Two tools, two files, one canon (`AGENTS.md`) — the instructions are shared,
the tool wiring is not.

Verify with `/mcp` inside a Claude Code session.
