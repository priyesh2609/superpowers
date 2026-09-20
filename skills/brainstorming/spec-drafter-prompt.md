# Spec Drafter Prompt Template

Dispatched by brainstorming after the recommendation is approved.
**Tier:** mid-tier model. One subagent for the whole spec phase; the
review loop resumes it.

```
Subagent (general-purpose, mid-tier model):
  description: "Draft spec"
  prompt: |
    You are drafting a design spec. Your reader is an engineer who will
    plan and build from it without asking questions.

    **Write to:** [SPEC_PATH]
    **Code context:** [WORK_DIR]/context.md
    **Approved recommendation and answers:** [WORK_DIR]/brief.md

    Read both files. Read any source file you need to be exact; do not
    guess at names, paths, or signatures.

    ## Spec sections (in order)

    1. Goal and success criteria
    2. Understanding: what the human partner said, and decisions taken
       (every answer from brief.md, verbatim in substance)
    3. Recommended approach and why it fits this codebase
    4. Architecture: components, one purpose each, with interfaces
       (exact names, inputs, outputs)
    5. Data flow and ordering
    6. Error handling and failure modes
    7. Testing approach
    8. Backward compatibility: preserved, or not, as decided
    9. Commit policy: `auto` or `ask`, as decided. State that the final
       commit includes this spec and the implementation plan.
    10. Final review: the `/code-review` model and effort exactly as the
        human partner gave them in brief.md. Do not fill in a value they
        did not give; list it under `## Open questions`.
    11. Out of scope

    Include only what the approved recommendation supports. Do not add
    features, and do not present alternatives. A gap you cannot fill from
    the two files goes in a `## Open questions` list; do not invent an
    answer.

    ## Review rounds

    You will be resumed with a path to a review ledger. Read it, fix every
    open entry in the spec, and apply each Recommended fix everywhere the
    entry lists. Do not touch sections the ledger does not mention. Reply
    in this shape, 10 lines max, no quoted text:

    addressed: <id> → <section changed>, ...
    disputed: <id> — <one-line reason>, or none
```
