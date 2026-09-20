# Review Loop

Shared by brainstorming (Spec phase) and writing-plans (Plan phase).
The spec loop finishes before the plan is drafted. Each phase runs at most
5 rounds.

**Core principle:** state lives in files, not in conversation. Every round
starts from the current artifact and one ledger file; the debate never
enters your context.

Tiers (frontier, mid-tier) and how to resume a subagent:
`../using-superpowers/references/model-tiers.md`. Vocabulary (phase,
round, batch, finding, ledger) is fixed:
`../using-superpowers/references/terminology.md`.

## Inputs

- `ARTIFACT` — the spec or plan being reviewed.
- `UPSTREAM` — for Plan phase, the approved spec. For Spec phase,
  `<work-dir>/context.md`.
- `LEDGER` — `<work-dir>/<phase>.review-ledger.md`, where `<work-dir>` is
  `.superpowers/design/<stem>/`. One file, overwritten every round.

## Roles

| Role | Tier | Lifetime |
|---|---|---|
| Drafter | mid-tier | one subagent for the whole phase, resumed each round |
| Reviewer | frontier | a fresh subagent every round |
| You | — | routes paths and one-line results only |

## The rounds

**Round 1 — exhaustive.** Dispatch a fresh reviewer with the prompt for
this phase (`spec-document-reviewer-prompt.md` or
`../writing-plans/plan-document-reviewer-prompt.md`), `ARTIFACT`,
`UPSTREAM`, `LEDGER`, and `MODE: full`. It must cover every category in one
pass; round 1 is where completeness matters. It writes `LEDGER` and
returns the return block below.

**Rounds 2-5 — delta.** If the return block shows no open Critical or High,
go to Exit. Otherwise send the drafter (resume) only the path to `LEDGER`
and the path to `ARTIFACT`. The drafter edits `ARTIFACT` and replies with
its return block. Then dispatch a **new** reviewer with `MODE: delta`,
`ARTIFACT`, `LEDGER`, and the drafter's changed-sections list. A delta
reviewer checks each open entry and looks for regressions the edits
introduced; it does not re-audit the whole artifact.

## Return blocks (hard cap: 15 lines each)

Reviewer returns:

```
round: N
open: Critical <a>, High <b>, Medium <c>, Low <d>
blocking ids: <ids of open Critical/High>
ask user: <ids of findings needing a human decision, or none>
```

Drafter returns:

```
addressed: <id> → <section changed>, ...
disputed: <id> — <one-line reason>, or none
```

Anything longer than the cap stays in the files. If a subagent pastes
findings or diffs into its reply, do not quote them onward, and do not
carry them into later dispatches. Your context holds one line per round:
the reviewer's `open:` line.

## State replacement

- `LEDGER` is replaced each round, never appended to. Resolved entries
  shrink to one line; open Critical/High entries keep their full text and
  forward-looking fix.
- Each reviewer starts empty: artifact, ledger, mode. It has no memory of
  earlier rounds and does not need any.
- The drafter is reused so it keeps what it learned about the artifact.
  Its replies are capped, so resuming it costs you nothing.
- A harness cannot delete your earlier turns. Keeping bulky exchanges
  inside subagents is how the loop stays flat.

## Severity

| Level | Meaning |
|---|---|
| Critical | Following the artifact builds the wrong thing, breaks existing behavior, or cannot be built |
| High | A likely failure, data-loss, security, or interface problem that surfaces during or right after implementation |
| Medium | A real gap with a workaround, or a risk that needs a decision |
| Low | Polish, wording, minor consistency |

## Forward-looking fixes (Critical and High)

Every Critical/High entry carries a **Recommended fix** that has already
worked through its consequences. The entry states: the root cause; the
fix; each other place in the artifact or codebase that shares the cause or
depends on the changed part; and what the fix changes downstream (tasks,
interfaces, tests). A fix that only patches the reported line is
incomplete. The drafter applies the fix everywhere the entry lists.

## Backward compatibility

Do not force it. A reviewer never adds a compatibility requirement on its
own. If the artifact changes something existing callers, data, or users
depend on and the artifact does not say whether to preserve it, the
reviewer files an entry marked `ASK` and does not guess. You collect all
`ASK` entries from a round, put them to your human partner in one batched
message, record the answers in the artifact's Decisions section, and
resume the drafter to apply them.

## Exit

- **Clean:** no open Critical or High. Report Medium/Low counts, with
  ledger path, to your human partner. Do not spend rounds on Medium/Low.
- **Round 5, Critical/High still open:** stop. Give your human partner the
  ledger path and the blocking ids with their one-line titles. Do not
  proceed to the next phase and do not run a sixth round.
- **Disputed finding:** the next reviewer rules on it. A dispute still
  open at Exit goes to your human partner with the ledger.

## Red Flags

| Thought | Reality |
|---|---|
| "I'll paste the findings into the drafter's message" | Send the ledger path. The file is the state. |
| "Reuse the reviewer so it remembers round 1" | A reviewer that remembers grows every round. The ledger is its memory. |
| "One more round, it's close" | Round 5 is the cap. Hand over the ledger. |
| "That fix touches only the reported line" | Trace who else shares the cause. Fix them together. |
| "They probably want backward compatibility" | Ask, in the batched message. |
