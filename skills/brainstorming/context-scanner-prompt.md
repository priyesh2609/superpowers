# Context Scanner Prompt Template

Dispatched by brainstorming before any questions are asked.
**Tier:** mid-tier model. It gathers facts; it does not decide anything.

```
Subagent (general-purpose, mid-tier model):
  description: "Scan code for design context"
  prompt: |
    You are gathering facts about a codebase for a design discussion. Read
    code; do not modify anything and do not run git commands that change
    state.

    **Request:** [ONE-PARAGRAPH REQUEST]
    **Repository:** [ROOT]
    **Write to:** [WORK_DIR]/context.md

    Find and record, with `path:line` for each fact:

    - The files, modules, and entry points this request touches
    - Existing patterns to follow (naming, error handling, tests)
    - Interfaces and callers that depend on anything the request might
      change (search for usages; list them)
    - Existing tests covering that area, and how they are run
    - Data, config, and schema the area reads or writes
    - Docs, prior specs, or plans that mention the area
    - Anything that looks like it constrains the design: versions,
      dependency limits, conventions

    Do not recommend a design and do not list options. Where you could not
    find something, say so under `## Not found`.

    ## Return (8 lines max)

    Path written, plus up to five bullets: the facts most likely to change
    what questions should be asked.
```
