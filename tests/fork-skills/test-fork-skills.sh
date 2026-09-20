#!/usr/bin/env bash
# Structural checks for the forked brainstorming / writing-plans / review-loop
# skills: links resolve, vocabulary is consistent, no named models, authoring
# skills never run git, required content is present, and task-brief honors
# wave headings.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILLS="$REPO_ROOT/skills"
TEST_ROOT="$(mktemp -d)"
FAILURES=0

cleanup() { rm -rf "$TEST_ROOT"; }
trap cleanup EXIT

pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; FAILURES=$((FAILURES + 1)); }

# Files whose text must follow the fixed vocabulary. terminology.md defines
# the banned words, and visual-companion.md predates the fork.
VOCAB_FILES=(
  "$SKILLS/brainstorming/SKILL.md"
  "$SKILLS/brainstorming/review-loop.md"
  "$SKILLS/brainstorming/spec-drafter-prompt.md"
  "$SKILLS/brainstorming/spec-document-reviewer-prompt.md"
  "$SKILLS/brainstorming/context-scanner-prompt.md"
  "$SKILLS/writing-plans/SKILL.md"
  "$SKILLS/writing-plans/plan-drafter-prompt.md"
  "$SKILLS/writing-plans/plan-document-reviewer-prompt.md"
  "$SKILLS/requesting-code-review/SKILL.md"
)

echo "Test: every relative .md link in the changed skills resolves"
for f in "${VOCAB_FILES[@]}" \
  "$SKILLS/executing-plans/SKILL.md" \
  "$SKILLS/subagent-driven-development/SKILL.md"; do
  dir="$(dirname "$f")"
  while IFS= read -r link; do
    [ -n "$link" ] || continue
    if [ -e "$dir/$link" ]; then
      pass "$(basename "$(dirname "$f")")/$(basename "$f") -> $link"
    else
      fail "$(basename "$(dirname "$f")")/$(basename "$f") -> $link (missing)"
    fi
  done < <(grep -o '\(\./\|\.\./\)[A-Za-z0-9_./-]*\.md' "$f" | sort -u)
done

echo "Test: banned vocabulary is absent"
for word in drip iteration iterations sprint milestone sub-task subtask stage stages; do
  hits="$(grep -n -i -w -- "$word" "${VOCAB_FILES[@]}" || true)"
  if [ -z "$hits" ]; then
    pass "no '$word'"
  else
    fail "found '$word':"
    printf '%s\n' "$hits" | sed 's/^/      /'
  fi
done
if grep -n -i "fix wave" "${VOCAB_FILES[@]}" "$SKILLS/subagent-driven-development/SKILL.md" >/dev/null; then
  fail "'fix wave' should be 'fix pass'"
else
  pass "no 'fix wave'"
fi

echo "Test: skill text names no models"
hits="$(grep -n -i -w 'opus\|sonnet\|haiku' "${VOCAB_FILES[@]}" || true)"
if [ -z "$hits" ]; then pass "tiers only"; else fail "named model:"; printf '%s\n' "$hits" | sed 's/^/      /'; fi

echo "Test: authoring skills never run git"
if grep -n 'git commit\|git add\|git push' "$SKILLS"/brainstorming/*.md >/dev/null; then
  fail "brainstorming contains a git command"
else
  pass "brainstorming has no git commands"
fi
count="$(grep -c 'git commit' "$SKILLS/writing-plans/SKILL.md" || true)"
if [ "$count" -eq 1 ]; then
  pass "writing-plans shows git only in the auto commit-step example"
else
  fail "writing-plans has $count 'git commit' occurrences (expected 1)"
fi

echo "Test: removed behaviors stay removed"
for phrase in "Propose 2-3 approaches" "one question per message" "Only one question per message"; do
  if grep -q -F "$phrase" "$SKILLS/brainstorming/SKILL.md" \
    && ! grep -q -F "Never ask one question per message" "$SKILLS/brainstorming/SKILL.md"; then
    fail "brainstorming still says '$phrase'"
  else
    pass "no '$phrase' instruction"
  fi
done

echo "Test: required content"
require() {
  local file="$1" needle="$2" desc="$3"
  if grep -q -F -- "$needle" "$file"; then pass "$desc"; else fail "$desc (missing: $needle)"; fi
}
require "$SKILLS/brainstorming/SKILL.md" "## Question batches" "brainstorming has Question batches"
require "$SKILLS/brainstorming/SKILL.md" "Minimize the back-and-forth by asking multiple independent questions" "brainstorming states the interrogation rule"
require "$SKILLS/brainstorming/SKILL.md" "leave no room for assumptions or confusion" "brainstorming forbids assumptions"
require "$SKILLS/brainstorming/SKILL.md" "Commit policy" "brainstorming asks the commit policy"
require "$SKILLS/brainstorming/SKILL.md" "Final review" "brainstorming asks the final-review model and effort"
require "$SKILLS/brainstorming/review-loop.md" "at most" "review-loop states the round cap"
require "$SKILLS/brainstorming/review-loop.md" "Forward-looking" "review-loop requires forward-looking fixes"
require "$SKILLS/brainstorming/review-loop.md" "replaced each round, never appended" "review-loop replaces state"
require "$SKILLS/brainstorming/review-loop.md" "Do not force it" "review-loop has the compatibility rule"
require "$SKILLS/writing-plans/SKILL.md" "**Commit policy:**" "plan header has Commit policy"
require "$SKILLS/writing-plans/SKILL.md" "**Final review:**" "plan header has Final review"
require "$SKILLS/writing-plans/SKILL.md" "## Waves" "writing-plans defines waves"
require "$SKILLS/requesting-code-review/SKILL.md" '/code-review <effort> --fix' "final review command form"
require "$SKILLS/using-superpowers/references/terminology.md" "## Hierarchy" "terminology defines the hierarchy"

echo "Test: final-review instructions carry the full self-review text"
instr="$SKILLS/requesting-code-review/final-review-instructions.md"
for needle in "## Self-Review Before Completing" "### 1. Against the request" "### 2. Against the codebase" \
  "### 3. Testing & completeness" "### 4. Report" "Do not mark the task complete if any requirement is unaddressed"; do
  require "$instr" "$needle" "instructions contain: $needle"
done

echo "Test: task-brief ends a task at a wave heading"
plan="$TEST_ROOT/plan.md"
cat >"$plan" <<'EOF'
# Fixture Plan

## Wave 1: Foundations

### Task 1: First
step one

## Wave 2: Dependents

Wave two description that must not leak into Task 1.

### Task 2: Second
step two
EOF
out1="$TEST_ROOT/brief1.md"
out2="$TEST_ROOT/brief2.md"
bash "$SKILLS/subagent-driven-development/scripts/task-brief" "$plan" 1 "$out1" >/dev/null
bash "$SKILLS/subagent-driven-development/scripts/task-brief" "$plan" 2 "$out2" >/dev/null
if grep -q "Wave 2" "$out1" || grep -q "must not leak" "$out1"; then
  fail "Task 1 brief leaked the next wave"
else
  pass "Task 1 brief stops before Wave 2"
fi
if grep -q "step one" "$out1" && grep -q "step two" "$out2" && ! grep -q "step one" "$out2"; then
  pass "briefs contain only their own task"
else
  fail "briefs contain the wrong task text"
fi

echo ""
if [ "$FAILURES" -eq 0 ]; then
  echo "All fork skill tests passed"
else
  echo "$FAILURES fork skill test(s) failed"
  exit 1
fi
