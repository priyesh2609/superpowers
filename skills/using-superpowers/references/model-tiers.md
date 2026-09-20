# Model Tiers

Skills name two tiers, never specific models:

- **Frontier model** — the most capable model available. Used for
  structural reasoning (the recommended approach) and every review.
- **Mid-tier model** — the daily-work model. Used for code scanning, data
  gathering, and first drafts of specs and plans.

Always set the tier explicitly when dispatching a subagent. An omitted
model inherits the session's model, which silently defeats the routing.

## Mapping

| Harness | Frontier | Mid-tier | How to set it |
|---|---|---|---|
| Claude Code | Opus | Sonnet | `model` parameter on the subagent dispatch |
| Codex | your most capable preset, highest reasoning effort | your default preset, medium reasoning effort | `model` and `reasoning_effort` on `spawn_agent` (see `codex-tools.md`) |
| Any other harness | most capable model it offers | its everyday model | per-dispatch model setting if the harness has one |

If the harness cannot choose a model per dispatch, run every role on the
session model and say so once in your first message. Do not stop.

Edit this table when your available models change; skill text stays the same.

## Resuming a subagent

Review loops resume the drafter between rounds so it keeps its own edit
context. Use the harness's resume mechanism (Claude Code: send the agent
another message; Codex: `followup_task`). If the harness has none,
dispatch a fresh drafter with the artifact path and the open findings.
Nothing is lost, because loop state lives in files.
