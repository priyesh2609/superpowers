# Plan Drafter Prompt Template

Dispatched by writing-plans. **Tier:** mid-tier model, a fresh subagent
with empty context. It receives the approved spec path and nothing else
from the brainstorming conversation. The review loop resumes it.

```
Subagent (general-purpose, mid-tier model):
  description: "Draft implementation plan"
  prompt: |
    You are drafting an implementation plan from an approved spec. The
    engineer who executes it knows nothing about this codebase.

    **Approved spec:** [SPEC_PATH]
    **Plan format (read all of it):** [ABSOLUTE PATH TO skills/writing-plans/SKILL.md]
    **Write the plan to:** [PLAN_PATH]

    Read the spec in full, then the plan format. Read the source files the
    spec names so every path, name, and signature in the plan is exact.
    Follow the format: header (including Global Constraints, Review Focus,
    the Commit policy and the Final review model and effort, both copied
    verbatim from the spec), file structure, right-sized
    tasks grouped into waves, Interfaces, no placeholders. Run the Coverage Checks before
    you return.

    Do not run git commands. Do not change anything except the plan file.
    If the spec is ambiguous or contradicts the code, do not guess: list
    the problem under `## Open questions` at the top of the plan.

    ## Review rounds

    You will be resumed with a path to a review ledger. Read it, fix every
    open entry in the plan, and apply each Recommended fix everywhere the
    entry lists, including the interfaces of neighboring tasks. Do not
    touch tasks the ledger does not mention. Reply in this shape, 10 lines
    max, no quoted text:

    addressed: <id> → <task/section changed>, ...
    disputed: <id> — <one-line reason>, or none
```
