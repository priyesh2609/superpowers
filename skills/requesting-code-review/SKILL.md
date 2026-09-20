---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
---

# Requesting Code Review

Dispatch a code reviewer subagent to catch issues before they cascade. The reviewer gets precisely crafted context for evaluation — never your session's history.

**Core principle:** Review early, review often.

## When to Request Review

**Mandatory:**
- After each task in subagent-driven development
- After completing major feature
- Before merge to main

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## How to Request

**1. Get git SHAs:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or: git merge-base origin/main HEAD
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Dispatch code reviewer subagent:**

Dispatch a `general-purpose` subagent, filling the template at [code-reviewer.md](code-reviewer.md)

**Placeholders:**
- `{DESCRIPTION}` - Brief summary of what you built
- `{PLAN_OR_REQUIREMENTS}` - What it should do
- `{BASE_SHA}` - Starting commit
- `{HEAD_SHA}` - Ending commit

**3. Act on feedback:**
- Fix Critical issues immediately
- Fix Important issues before proceeding
- Note Minor issues for later
- Push back if reviewer is wrong (with reasoning)

## Final Review via /code-review

When the plan header has a `Final review` line (`model:` and `effort:`
values your human partner chose while the plan was written), the final
whole-branch review runs through the harness's `/code-review` command
instead of the template above. Both execution skills call this section.

1. **Dispatch one background subagent** on the model named in the line,
   set explicitly. Run it in the background where the harness supports
   that, and wait for its completion notice; do nothing else on the branch
   meanwhile.
2. **Its prompt** carries: the exact command to run,
   `/code-review <effort> --fix "<contents of final-review-instructions.md>"`,
   with the file's text inserted verbatim as the quoted argument; the
   paths of the spec and the plan (the "original ask" the instructions
   refer to); and the Commit policy. Invoke the command through the
   harness's skill or command mechanism. If the subagent cannot invoke
   it, it stops and replies BLOCKED. It does not substitute its own review.
3. **Its reply** is capped at 15 lines: verdict line, findings fixed,
   findings left open with severity, files changed, and the path of any
   report file it wrote. Details stay in that file.
4. **Commits.** `--fix` edits code. Under Commit policy `auto` the subagent
   commits its fixes; under `ask` it leaves them uncommitted and lists the
   files, and you ask your human partner before committing.
5. **If BLOCKED**, tell your human partner, then fall back to the
   dispatch in "How to Request" on the same model. Say so in the final
   message.

Effort and model come from your human partner's plan. Do not change them.

The instructions text lives in
[final-review-instructions.md](final-review-instructions.md); edit it
there, not in the plan.

## Example

```
[Just completed Task 2: Add verification function]

You: Let me request code review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch code reviewer subagent]
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types
  PLAN_OR_REQUIREMENTS: Task 2 from docs/superpowers/plans/deployment-plan.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

[Subagent returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

You: [Fix progress indicators]
[Continue to Task 3]
```

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "I'll just review the diff myself instead of dispatching a reviewer" | You're the coordinator — reviewing the diff inline burns the context window you need to keep driving the work. Dispatch a reviewer subagent: the diff and the evaluation live in its context, and only the findings come back to you. |
| "The reviewer needs my whole session history to understand the change" | Hand it precisely crafted context, never your session's history. That keeps the reviewer on the work product, not your thought process. |

## Red Flags

**Never:**
- Skip review because "it's simple"
- Ignore Critical issues
- Proceed with unfixed Important issues
- Argue with valid technical feedback

**If reviewer wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification

See template at: [code-reviewer.md](code-reviewer.md)
