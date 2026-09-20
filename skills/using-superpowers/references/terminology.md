# Terminology

One vocabulary for every skill, prompt, plan, and message to your human
partner. Use these words for these things and no others.

## Hierarchy

```
Workflow
└── Phase        Brainstorm → Spec → Plan → Execution → Final review
    ├── Round    one review-and-fix cycle inside a phase (max 5)
    └── Wave     an ordered group of tasks inside the Plan and Execution phases
        └── Task
            └── Step
```

| Term | Meaning |
|---|---|
| **Workflow** | One request, from first question to merge-ready branch. |
| **Phase** | A part of the workflow with its own artifact and its own approval. Exactly five: **Brainstorm** (understanding and recommendation), **Spec** (the design doc), **Plan** (the implementation plan), **Execution** (the tasks), **Final review** (the `/code-review` pass). |
| **Round** | One review-and-fix cycle: a reviewer produces findings, the drafter or implementer fixes them. The Spec and Plan phases run at most 5 rounds each. A task's fix loop also counts in rounds (max 5). |
| **Wave** | An ordered group of tasks in a plan. Tasks in one wave do not depend on each other; a later wave may depend on an earlier one. Waves run in order. Execution still runs one task at a time within a wave. |
| **Task** | The smallest unit with its own test cycle and its own review. Numbered across the whole plan (Task 1, Task 2, …), never restarting per wave. |
| **Step** | One 2-5 minute action inside a task. |

## Related nouns

| Term | Meaning |
|---|---|
| **Batch** | One message holding every independent question. A question that depends on an earlier answer waits for the next batch. |
| **Finding** | One issue a reviewer reports, with a severity: Critical, High, Medium, Low. |
| **Review ledger** | The one file a review loop overwrites each round, listing open findings. |
| **Progress ledger** | The execution phase's record of task results and rulings. |
| **Fix pass** | One dispatch that fixes all findings of one review together. |
| **Work directory** | `.superpowers/design/<stem>/`, holding transient loop state. |
| **Turn** | One model response. Never a review cycle; that is a round. |

## Words not to use

| Do not say | Say |
|---|---|
| iteration, cycle, loop turn | round |
| stage, milestone, step (for a phase) | phase |
| sprint, batch of tasks, group | wave |
| sub-task, work item | task, or step if it is one action |
| fix wave | fix pass |
| ask one at a time, question by question | ask in batches |
