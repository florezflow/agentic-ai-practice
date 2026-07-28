# `.github/aw/`

Working directory for the [`gh aw`](https://github.com/github/gh-aw) CLI extension.
Everything in here is **generated** — you do not hand-edit it.

## `actions-lock.json`

A dependency lock file. Same idea as `package-lock.json` in Node or `Gemfile.lock` in Ruby:
it records the **exact** version of every GitHub Action the compiled workflows use.

```json
"github/gh-aw-actions/setup@v0.83.1": {
  "repo":    "github/gh-aw-actions/setup",
  "version": "v0.83.1",
  "sha":     "8bdba8075360648fe6802302a5b4e016361dc6ac"
}
```

Read it as: *"when my workflows say `v0.83.1`, they mean this commit and no other."*

### Why a tag isn't enough

A Git tag is a movable label. Whoever owns `github/gh-aw-actions` can point `v0.83.1` at
different code tomorrow, and every workflow referencing that tag would silently start running
it. A commit SHA is a hash of the content — it cannot be repointed.

This matters more than usual here, because these actions run **inside** your workflow with
access to the repository and its secrets. Pinning to a SHA is the difference between "I trust
this code" and "I trust whoever currently controls that tag".

You can see the result in the generated workflows:

```yaml
uses: github/gh-aw-actions/setup@8bdba8075360648fe6802302a5b4e016361dc6ac # v0.83.1
```

The SHA is what runs; the trailing comment is only there so a human can read it. That line
appears 7–8 times per `.lock.yml` file, which is why the mapping lives in one lock file rather
than being repeated by hand.

### The two actions

| Action | Does |
|---|---|
| `github/gh-aw-actions/setup` | Prepares the agentic runtime — sandbox, firewall proxy, MCP gateway, safe-output plumbing |
| `github/gh-aw-actions/setup-cli` | Installs the `gh aw` CLI itself inside the runner |

Both currently resolve to the same SHA because they live in one repository.

### Maintaining it

`gh aw` writes this file. To update the pinned versions:

```bash
gh aw upgrade    # bump actions and recompile
gh aw compile    # re-resolve anything missing
```

Delete an entry and run `gh aw compile` — it is restored automatically, byte-for-byte.

## Why this explanation is in a README and not in the JSON

Two reasons, and the second one is the interesting one:

1. **JSON has no comment syntax.** No `//`, no `#`.
2. **A `"_comment"` key does not survive.** JSON tolerates extra keys, and `gh aw compile`
   leaves one alone as long as it has no reason to rewrite the file — so it *looks* like it
   works. The moment gh-aw actually regenerates the lock (a version bump, a missing entry), the
   key is dropped without a word.

   That is worse than having no comment at all: you would be relying on documentation that
   quietly disappeared. Verified by deleting an entry and recompiling — the file came back
   byte-for-byte identical to the original, comment gone.

The general rule for this repository: **generated files carry no hand-written content.** The
same applies to `.github/workflows/*.lock.yml` (edit the `.md`, run `gh aw compile`) and to
`agentics-maintenance.yml`.

## See also

- [`docs/agentic-workflows.md`](../../docs/agentic-workflows.md) — how the workflows work
- [`docs/reference-links.md`](../../docs/reference-links.md) — official documentation index
- [`mcp.json`](mcp.json) is *not* here — it lives at `.github/mcp.json` and configures the
  `gh aw` authoring agent, which is a different thing from the MCP servers your custom agents
  use. See [`docs/mcp-and-firewall.md`](../../docs/mcp-and-firewall.md).
