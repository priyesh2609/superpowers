# Fork skills: batched brainstorming, single recommendation, tiered review loop

Nothing here is committed; the fork owner reviews the working-tree diff.

## Decisions (from the fork owner)

- Keep the Spike / Bounded / Architectural router. Spike and Bounded also get batched questions and a single recommendation.
- Skill text names no models. Two tiers only: **frontier model** and **mid-tier model**. The per-harness mapping lives in one file: `skills/using-superpowers/references/model-tiers.md`.
- Reuse the drafter across review rounds (resume); dispatch a fresh reviewer each round.
- Skills never touch git. Commit policy is asked during brainstorming, recorded in the spec, copied to the plan header, and obeyed by the execution flows (`auto` or `ask`). The final commit includes the spec and the plan.
- Keep existing paths under `docs/superpowers/specs|plans/`. Transient loop state goes in `.superpowers/design/<stem>/`.
- Round 5 with Critical/High still open: stop and hand the ledger to the human partner.

## Files

| File | Change |
|---|---|
| `skills/brainstorming/SKILL.md` | Rewrite process: batched questions, single recommendation, tiered drafting, loop, no git |
| `skills/brainstorming/review-loop.md` | New. Shared state-replacement review loop (spec and plan phases) |
| `skills/brainstorming/spec-document-reviewer-prompt.md` | Rewrite: exhaustive round 1, severity scale, forward-looking fixes, delta rounds |
| `skills/brainstorming/spec-drafter-prompt.md` | New. Mid-tier drafter, resumed across rounds |
| `skills/brainstorming/context-scanner-prompt.md` | New. Mid-tier code scan into `context.md` |
| `skills/writing-plans/SKILL.md` | Input is only the approved spec; clean-context drafter; loop; commit policy in header; no Commit steps |
| `skills/writing-plans/plan-document-reviewer-prompt.md` | Rewrite to match the spec reviewer |
| `skills/writing-plans/plan-drafter-prompt.md` | New. Mid-tier drafter with empty context |
| `skills/executing-plans/SKILL.md` | Commit step obeys the plan's Commit policy |
| `skills/subagent-driven-development/{SKILL.md,implementer-prompt.md}` | Implementer commit step obeys the plan's Commit policy |
| `skills/using-superpowers/references/model-tiers.md` | New. Tier to model mapping per harness |

## Verification

- Run `tests/codex/test-package-codex-plugin.sh` and `tests/hooks` (skill file lists and hook output must still work).
- Grep the changed skills for named models, removed phrases ("2-3 approaches", "one at a time"), and `git commit` in authoring skills.

## Addendum: final review via /code-review

- Brainstorming's question batch asks for the `/code-review` model and effort. It records the user's exact words and names no default.
- The spec has a Final review section. The plan header copies it as `Final review: model, effort`. A missing value is a High `ASK` finding, and the user is asked before the plan is presented.
- `requesting-code-review/SKILL.md` gains "Final Review via /code-review": one background subagent on the named model runs `/code-review <effort> --fix "<instructions>"`. The reply is capped at 15 lines. If the subagent cannot invoke the command it returns BLOCKED, and the controller falls back to the old reviewer on the same model.
- `requesting-code-review/final-review-instructions.md` holds the self-review instructions verbatim.
- SDD and executing-plans Final Review sections use this path when the header line exists. Otherwise they keep the old flow. Fix commits follow the Commit policy.

## Addendum: terminology and question batches

- `skills/using-superpowers/references/terminology.md` fixes the vocabulary. Hierarchy: workflow > phase (Brainstorm, Spec, Plan, Execution, Final review) > round | wave > task > step. Related nouns: batch, finding, review ledger, progress ledger, fix pass, work directory, turn.
- Banned words in the fork's skills: drip, iteration, stage, sprint, milestone, sub-task, "fix wave" (now "fix pass"). The old "phase `spec`" parameters became "Spec phase" and "Plan phase".
- Plans group tasks into `## Wave N: <name>` headings. Tasks stay numbered across the plan. `task-brief` ends a task at a wave heading so a wave's description never leaks into the previous task's brief. Execution stays one task at a time.
- Question rule (the user's wording): minimize the back-and-forth by asking multiple independent questions per batch, leaving no room for assumptions or confusion. Dependent questions wait for the next batch. Every question carries a default. Asking stops only when no assumption is left.

## Testing

| Layer | What | Result |
|---|---|---|
| Structural | `tests/fork-skills/test-fork-skills.sh`: links resolve, banned vocabulary, no named models, no git in authoring skills, required content, wave-aware `task-brief` | 59 checks pass |
| Existing | `tests/hooks/test-session-start.sh`, `tests/claude-code/test-sdd-workspace.sh`, `tests/claude-code/test-executing-plans-scripts.sh` | pass |
| Existing | `tests/codex/test-package-codex-plugin.sh` | 1 failure (zip timestamp timezone), identical on the untouched baseline |
| Behavior | A fresh subagent follows brainstorming on a sample request and its first message is graded against the rules | 1 run, passed all checks; details in the session report |
