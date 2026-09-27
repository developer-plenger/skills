---
name: review
description: >
  Review an implemented task against its plan's spec and acceptance criteria, and
  record severity-classified findings in
  specs/NN-<plan-slug>/reviews/TASK-NNN.md. Use for /review,
  "/review NN-<plan-slug>/NN-pK", auditing a task before merge, or re-reviewing
  after a /fix pass. Finds and records problems; never edits source code.
---

# Review

Judge one implemented task against the specification and its acceptance criteria, and leave a written record of what you found. `/review` does not edit source code: a review that quietly fixes what it finds destroys the record the user is relying on. Remediation belongs to `/fix`.

## 1. Load context

Read, in order:

1. `AGENTS.md` — the registered workflow, artifact paths and skill rules.
2. `context.md` — the project's memory, including the plan ledger.
3. The target plan's `spec.md`, opened at the sections the task descends from.
4. The slice file under `specs/NN-<plan-slug>/slice/` that holds the task.
5. The task block itself.

Missing artifact → stop and name the skill that produces it: `AGENTS.md` → `/init`, `context.md` → `/plan`, plan spec → `/plan`, slice file → `/slice`. Never invent the missing content.

Completion criterion: you can state the task title, its plan, its stage, and its acceptance criteria without having guessed any of them.

## 2. Resolve the invocation

`/review NN-<plan-slug>/TASK-003` — one task; `/review NN-<plan-slug>/NN-pK` — that stage's tasks, in file order, one review per task.

Task IDs restart per plan, so a bare `TASK-003` is enough only when exactly one plan folder holds it; otherwise ask which plan. Findings are written into the plan folder the task belongs to, so the plan has to be known before the review starts.

For a stage sweep, skip every task whose `Implemented` box is unchecked and report it as not reviewable: reviewing code that was never built produces findings about nothing.

Completion criterion: a concrete list of tasks, each mapped to its plan, stage and file.

## 3. Read the requirement

Open that plan's `spec.md` and read the sections the task descends from — section 8 (Functional Requirements), section 19 (Acceptance Criteria), and any other section the task's description names. Read those sections rather than the whole file; `context.md` already carries the project summary.

A plan spec describes only that plan's delta, so a requirement the task implements may have been introduced by an earlier plan. When the task's spec section says `None` or points at an earlier plan, open that plan's `spec.md` too: the requirement being implemented lives there, and reviewing against the wrong plan's §8 produces findings about a document that never claimed this behaviour.

The spec outranks the task's own criteria: when the task's acceptance criteria are narrower than what the spec requires, that gap is itself a finding.

Completion criterion: for each acceptance criterion, you can name the spec statement it implements.

## 4. Read the implementation

Read the actual code — every changed file, not the diff summary alone. Trace each acceptance criterion to the code path that satisfies it; a criterion with no reachable code path is unmet, whatever the implementation summary claims.

Read the neighbouring code too: whether this change reuses what exists or invents a parallel implementation is only visible against the surrounding repository.

Completion criterion: every changed file read, and for each acceptance criterion either a satisfying code path or a finding that it is missing.

## 5. Review the dimensions

Read `references/review-checklist.md` and work its dimensions in order against the code you just read. It carries the questions, the severity definitions and the bar a claim must clear before it counts as a finding: a claim with no location and no failing scenario is an opinion, not a finding.

Completion criterion: every dimension answered — either findings, or one line saying what you examined and why it was clean.

## 6. Write the review

Read `references/findings.md` for the exact `specs/NN-<plan-slug>/reviews/TASK-NNN.md` layout and the finding lifecycle. Write one file per task — `specs/02-monthly-budgets/reviews/TASK-003.md` — with a Summary that names the evidence examined, the findings, the recommended change order, and a Verification block recording what you actually read or ran.

Re-reviewing after a fix: append to or update the existing findings in place. The review doc is a record — rewriting it erases the evidence trail the next reader depends on.

Completion criterion: the file exists, every finding carries severity, location, failing scenario and suggested change, and the Status block states an explicit `Reviewed:` verdict.

## 7. Update task state

Read `references/task-state.md` for the transition this skill owns.

Check `Reviewed` only when nothing of severity Medium or higher is unresolved — Low findings may stay open, and a finding marked `Fixed` that this review has not re-confirmed counts as Open. Otherwise leave the box at `- [ ]` and name the blocking findings in the report. Never clear a box; only `/fix` unchecks.

Completion criterion: the slice file's `Reviewed` box matches the Status block in the review doc.

## 8. Update context.md

Set `Current Phase` to `REVIEW` — the field holds exactly one of the seven step names (`INIT`, `PLAN`, `SLICE`, `EXEC`, `REVIEW`, `CHECK`, `FIX`), with no task ID, no plan name, no stage name and no free text.

A review flips the `Reviewed` box, and that can be the box that makes a stage `DONE` — so update the state slot of this plan's line in `Current Development Status` when it did, and leave it alone when it did not. `p0 ✓` means every task in that stage has all three boxes checked, which is the stage's state, not the review's. Leave the summary clause alone: you flip a box, you do not restate what the plan builds. Never touch another plan's line.

Completion criterion: the cursor names the step that just ran, and this plan's ledger line matches the boxes on disk.

## 9. Report

Tell the user:

- what was reviewed and how many findings, by severity;
- what state changed — the box flipped, or stayed unchecked and why;
- what to run next: `/fix NN-<plan-slug>/TASK-NNN#FINDING-NNN` for unresolved findings, then
  `/check` for proof of the acceptance criteria, or `/check` alone when the
  review came back clean.

Completion criterion: the user knows the verdict, the exact state change, and
the one command to run next.
