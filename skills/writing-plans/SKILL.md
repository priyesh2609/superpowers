---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** If working in an isolated worktree, it should have been created via the `superpowers:using-git-worktrees` skill at execution time.

**Save plans to:** `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
- (User preferences for plan location override this default)

## How This Skill Runs

**Input: the approved spec path, and nothing else.** Do not carry over the
brainstorming conversation, its ledger, or your own summary. The spec is
the whole handoff.

Tiers (frontier, mid-tier) and resuming a subagent:
`../using-superpowers/references/model-tiers.md`. Vocabulary (workflow,
phase, round, wave, task, step) is fixed:
`../using-superpowers/references/terminology.md`.

1. **Draft.** Dispatch a plan drafter (`./plan-drafter-prompt.md`) on the
   mid-tier model, as a fresh subagent with empty context. Give it the spec
   path, this file's absolute path as the plan format, and the plan's
   output path. Nothing else.
2. **Review.** Run `../brainstorming/review-loop.md` for Plan phase, up to
   5 rounds. The reviewer prompt is `./plan-document-reviewer-prompt.md`.
   The spec has already been approved; the loop reviews the plan against it.
3. **Hand over.** See Execution Handoff.

This skill never runs git. It writes the plan; the plan's Commit policy
tells the execution skills what to do about commits.

The rest of this file describes what the plan must contain. The drafter
follows it and the reviewer checks it.

## Scope Check

If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure - but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

## Task Right-Sizing

A task is the smallest unit that carries its own test cycle and is worth a
fresh reviewer's gate. When drawing task boundaries: fold setup,
configuration, scaffolding, and documentation steps into the task whose
deliverable needs them; split only where a reviewer could meaningfully
reject one task while approving its neighbor. Each task ends with an
independently testable deliverable.

## Waves

Group tasks into waves. A wave is an ordered group of tasks that do not
depend on each other; a later wave may depend on an earlier one. Put a task
that consumes another task's interface in a later wave than the task that
produces it. Headings look like `## Wave 1: <name>`, with the wave's tasks
beneath it. Tasks are numbered across the whole plan (Task 1, Task 2, …)
and never restart per wave. A small plan is a single `## Wave 1`. Execution
still runs one task at a time; waves make the dependency order explicit.

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

**Spec:** [path to the spec/design doc this plan implements — the plan
argues from the spec, so the spec travels with it; executors read both]

**Commit policy:** [`auto` or `ask`, copied from the spec's Commit policy
section. `auto`: the execution skills commit at each task's commit step.
`ask`: they stop and get your human partner's approval before each
commit. The final commit includes this plan and its spec.]

**Final review:** [`model: <value>`, `effort: <value>`, copied verbatim
from the spec's Final review section. After the last task, the execution
skills run `/code-review <effort> --fix` on a background subagent using
this model. If the spec lacks either value, do not invent one: your human
partner is asked before the plan is finished.]

## Global Constraints

[The spec's project-wide requirements — version floors, dependency limits,
naming and copy rules, platform requirements — one line each, with exact
values copied verbatim from the spec. Every task's requirements implicitly
include this section.]

## Review Focus

[The five input classes or failure modes the spec implies but no task's
tests exercise that are most likely to bite a person using this software
— one line each, naming the input or condition and the behavior a
reasonable person would expect, most likely first. The spec is a vision
document: it says what the software must do, not everything it will
meet, and its silence on an input is not permission for that input to
break the program. Write the list here, once, with the spec in front of
you. Then, for each line, add the test that pins it to the task that
owns the code, in that task's own step style.]

---
```

## Task Structure

````markdown
## Wave W: [Name]

### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Interfaces:**
- Consumes: [what this task uses from earlier tasks — exact signatures]
- Produces: [what later tasks rely on — exact function names, parameter
  and return types. A task's implementer sees only their own task; this
  block is how they learn the names and types neighboring tasks use.]

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit** (worded by the plan's Commit policy)

`auto` — the step contains the exact commands:

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```

`ask` — the step reads: "Stop and ask your human partner to approve
committing `tests/path/test.py` and `src/path/file.py` as
`feat: add specific feature`. Commit only after approval."
````

The last task's commit step also says that the final commit includes the
plan and its spec (`docs/superpowers/plans/<plan>.md`,
`docs/superpowers/specs/<spec>.md`).

## No Placeholders

Every step must contain the actual content an engineer needs. These are **plan failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — the engineer may be reading tasks out of order)
- Steps that describe what to do without showing how (code blocks required for code steps)
- References to types, functions, or methods not defined in any task

## Coverage Checks

The drafter runs these before returning each draft, and the reviewer
checks them again. Check the plan against the spec with fresh eyes.

**1. Spec coverage:** Skim each section/requirement in the spec. Can you point to a task that implements it? List any gaps.

**2. Placeholder scan:** Search your plan for red flags — any of the patterns from the "No Placeholders" section above. Fix them.

**3. Type consistency:** Do the types, method signatures, and property names you used in later tasks match what you defined in earlier tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

**4. Review Focus:** For each input class or failure mode the spec implies, is there a task whose tests exercise it? The five uncovered ones most likely to bite a person go in the Review Focus section, and each line there gets its test added to the owning task. An empty section means you checked and found none, not that you skipped the check.

**5. Commit policy:** The header's Commit policy matches the spec, and every task's commit step is worded for it.

**6. Final review:** The header's Final review line carries the model and effort exactly as the spec records them. If either is missing, list it under `## Open questions`, and the controller asks your human partner before the plan is presented.

Fix issues inline. If a spec requirement has no task, add the task.

## Execution Handoff

If the plan's `## Open questions` lists a missing Final review model or
effort, ask your human partner now, in one message with any other open
questions, and resume the drafter with the answers before continuing.

After the review loop exits clean, link the plan for your human partner
to read. Report the loop's last `open:` line. If Critical or High findings
are still open after round 5, give them the ledger path instead of
proceeding. When the plan is approved, delete the work directory
`.superpowers/design/<stem>/`. If they have already explicitly supplied an execution method, ask
them to review the plan and confirm it captures what they want; wait for that
review before implementation, then use the preserved method. Otherwise, ask
them to review the plan and choose an execution method before implementation.

**When no execution method has already been supplied:**

**"Plan complete and saved to `docs/superpowers/plans/<filename>.md`. Please review the plan. Which execution approach would you prefer?**

- **Subagent-driven** - A fresh subagent implements each task and a fresh reviewer checks it before the next one starts, then a whole-branch review at the end. Most thorough; costs a fresh context per task and per review.
- **Native** - I implement every task myself in this session, the way this harness runs work, then one fresh reviewer on the most capable model checks the whole branch. Cheapest and fastest; no independent review until the end. Runs well with a mid-tier session model, since the plan carries the design.

**For this plan I recommend <one of the two>, because <one sentence from the plan: how much the tasks depend on each other's interfaces, how many there are, what a shipped mistake would cost>. Does the plan capture what you want, and which approach should we use?"**

**When an execution method has already been supplied:**

**"Plan complete and saved to `docs/superpowers/plans/<filename>.md`. Please review the plan. Does it capture what you want?"**

**If Subagent-driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development

**If Native chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:executing-plans
