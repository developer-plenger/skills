---
name: fix
description: >
  Remediate review findings and check failures with the smallest root-cause
  change, record it in docs/fixes/TASK-NNN.md, and reset the checkboxes its
  change invalidated. Use for /fix, "fix TASK-001", "fix TASK-001#FINDING-002",
  "fix phase-01", "address these findings", or repairing a failing check before
  re-review. The only skill that edits source code after /exec.
---

# Fix

Remediate what `/review` found and `/check` failed, and leave a record of the
change. `/fix` is the only skill that edits source code after `/exec` — review
finds, check proves, fix repairs. It never checks a box; it only clears the
ones whose evidence its change invalidated.

## 1. Load context

Read, in order:

1. `AGENTS.md` — the registered workflow, artifact paths and skill rules.
2. `docs/plan/CONTEXT.md` — what the project actually is.
3. The phase file under `docs/phases/` that holds the task.
4. The task block itself, plus the finding or failure you are fixing.

Missing artifact → stop and name the skill that produces it: `AGENTS.md` →
`/init`, `docs/plan/CONTEXT.md` → `/plan`, phase file → `/slice`. A missing
review or check doc for the target → stop and say which skill produces it.

Completion criterion: you can state what is wrong, where, and what evidence
establishes it, without having guessed any of them.

## 2. Resolve the invocation

- `/fix TASK-003` — the task's open findings in `docs/reviews/TASK-003.md` and
  its failures in `docs/checks/TASK-003.md`.
- `/fix TASK-003#FINDING-002` — exactly that finding.
- `/fix phase-01` — every task in the phase that has something to fix.

`TASK-NNN#FINDING-NNN` numbers findings **inside their own review doc**: the
reference resolves against `docs/reviews/TASK-003.md` only. Locate the task the
same way the other skills do — grep the ID under `docs/phases/`, expect exactly
one match.

For a phase sweep: collect the findings and failures per task, then handle them
one at a time, never overlapping edits.

Completion criterion: an explicit list of findings and failures to remediate,
each with its task.

## 3. Find the root cause

Read `references/remediation.md` before touching code — it carries the
discipline and a worked example.

A finding names a symptom. Grep every caller of the function you are about to
touch, and fix it where all callers route through: one guard in the shared
function is a smaller diff than a guard in every caller, and patching only the
path the finding names leaves the sibling callers broken.

Completion criterion: you can name the exact line that produces the failure,
and why every caller reaching it is now covered.

## 4. Change the smallest thing

Fix the finding, nothing else. A drive-by refactor while fixing makes the
change unreviewable and the fix's verification worthless — the reviewer can no
longer see which change addressed which symptom.

An unrelated problem you notice becomes its own finding or its own task, not a
free fix in this pass. Scope discipline is what lets `/review` re-confirm this
fix in one read.

Completion criterion: `git diff` (or the file listing) contains only changes
that serve the targeted findings.

## 5. Guard the exceptions

Stop and hand back to the user, rather than forcing the fix through, when:

- **The fix invalidates the finding's own reproduction** — the finding
  described a real scenario and your change makes that scenario unreachable
  for a reason unrelated to the cause. Either the finding was misdiagnosed or
  the fix is wrong; say which and stop.
- **The SPEC says the behaviour is intended** — section 9 (Business Logic),
  section 16 (Constraints) or section 18 (Decisions) settles it against the
  finding. The SPEC outranks the reviewer's opinion; report the conflict.
- **The fix requires changing an acceptance criterion**, a public API contract,
  or data the user owns. Those are decisions above this skill's authority.

Completion criterion: either a remediation you can justify, or a written reason
the user must decide.

## 6. Re-verify the original failure

Run the scenario that proved the problem, and show the new outcome: the failing
test now passing, the malformed request now returning the documented response,
the reproduction steps now clean. Re-run the specific command, not only the
suite.

If the finding came from `/check`, re-run the command recorded in
`docs/checks/TASK-NNN.md`. If it came from `/review`, re-run or re-read the
scenario in the finding's `Problem:` field.

Completion criterion: recorded output showing the original failure no longer
reproduces. A fix with no re-run is unverified and does not close the finding.

## 7. Write the fix record

Read `references/remediation.md` for the exact `docs/fixes/TASK-NNN.md` layout.
Write one file per task, one `## FINDING-NNN — <title>` section per remediated
item, plus the closing `## Result` naming the boxes reset.

Reference the finding by its `FINDING-NNN` identifier so `/review` can match the
record to it and mark it Fixed on the next pass. `/fix` does not edit the review
doc — the reviewer re-confirms, the fix only claims.

Completion criterion: the file exists, every targeted item has root cause,
change and verification, and `## Result` names the reset boxes.

## 8. Reset invalidated checkboxes

Read `references/task-state.md` for the reset rule.

A fix that changes code always resets `Reviewed` and `Tested`: their evidence
was about code that no longer exists. Reset `Implemented` too when the finding
showed the task was never really implemented. A fix that changed only
documentation or tests resets only what it invalidated, and says which.

Reset means writing `- [ ]` over the existing `- [x]`. **`/fix` never checks a
box** — `/exec`, `/review` and `/check` check; `/fix` only unchecks.

Completion criterion: every invalidated box is `- [ ]`, and the `## Result`
section names exactly those boxes with the reason.

## 9. Update CONTEXT.md

Set `## Current Phase` in `docs/plan/CONTEXT.md` to `FIX` — the field holds
exactly one of the seven step names (`INIT`, `PLAN`, `SLICE`, `EXEC`, `REVIEW`,
`CHECK`, `FIX`), with no task ID and no free text. Change nothing else in that
file.

Completion criterion: `Current Phase` names the step that just ran.

## 10. Send the task back

Tell the user:

- which findings and failures were remediated, with the verification output for
  each;
- what was not remediated, and why — the conflict with the SPEC, the decision
  above this skill's authority;
- which checkboxes were reset;
- what to run next: `/review TASK-NNN` and `/check TASK-NNN`. Always both: a
  code change invalidates the review's verdict and the check's evidence alike,
  and only those skills may restore either box.

Completion criterion: the user knows what was remediated, what was not and why,
which boxes were reset, and that `/review` and `/check` must both run again.
