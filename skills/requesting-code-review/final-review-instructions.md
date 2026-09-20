## Self-Review Before Completing

Before marking this task done, review your own diff:

### 1. Against the request
- Re-read the original ask. Does the change do exactly what was requested — no more, no less?
- Any requirement, edge case, or constraint mentioned in the request that wasn't addressed? List it explicitly if so.
- Any assumption you made that wasn't stated? Call it out rather than silently deciding.
- If you deviated from what was asked (different approach, skipped part, added something extra), state why.

### 2. Against the codebase
- Does this match existing patterns/conventions in the surrounding code (naming, error handling, structure), or did you introduce a new way to do something that already has a way?
- Does it break or duplicate existing functionality elsewhere in the codebase? Search for related/existing implementations before assuming this is new.
- Are all call sites/consumers of anything you changed (function signatures, API contracts, schemas) updated accordingly?
- Any dead code, leftover debug statements, or unused imports from your own edit?

### 3. Testing & completeness
- Map every requirement/acceptance criterion from the ask to an actual test — walk the list and check each one off against a real test, not "it should work."
- Trace the full lifecycle end-to-end: entry point → input validation → business logic → persistence → downstream effects (events, cache, notifications) → response. Don't unit-test the middle and assume the ends connect.
- Exercise the real integration at least once, not just a mocked version of it — mocks can pass while the actual query, serialization, or auth middleware silently breaks the flow.
- Validate at every boundary the data crosses: reject malformed input at the API layer, revalidate before persistence, don't blindly trust upstream validation.
- Verify side effects actually fire and are correct: event payloads match schema, cache is invalidated/updated, notifications/webhooks trigger, audit logs are written.
- Check the reverse path: if this creates something, can it be read back correctly everywhere it's surfaced (API response, list views, related resources)? If it updates something, does every surface reflect the update?
- Test failure and partial-failure paths, not just success — if a downstream call fails mid-flow, is state left consistent, or does it need compensation?
- Test concurrent/duplicate requests where relevant — same request retried, or two requests racing the same resource.
- Run the full existing test suite, not just new tests — confirm nothing else broke and no existing contract changed unintentionally.
- If multiple services/consumers are touched, verify each one independently — "it compiled" isn't proof it's wired correctly.
- Confirm it's observable in a real run: point to an actual log line, response, or DB row proving it worked — not just "tests pass."

### 4. Report
End with:
- One line: fully satisfies the request / partially — here's what's missing or deviated, and why.
- Files changed, one line per file on what changed.
- Which requirements/edge cases were verified with a real test vs. assumed.
- Any open questions or assumptions that need confirmation.

Do not mark the task complete if any requirement is unaddressed or unverified — flag it instead of silently dropping it.
