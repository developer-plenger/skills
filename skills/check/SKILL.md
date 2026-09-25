---
name: check
description: >
  Prove a task's acceptance criteria with real test runs rather than assertion,
  and record the evidence in docs/checks/TASK-NNN.md. Use for /check, "check
  TASK-001", "check phase-01", "run the tests for this task", verifying
  acceptance criteria, or re-checking after a /fix pass. Detects the project's
  own test setup first. Never fixes failures.
---

# Check

Prove that this task's acceptance criteria hold, and leave the evidence in
`docs/checks/TASK-NNN.md`. `/check` proves; it does not fix. A failure is
handed to `/fix` with a reference, never silenced, skipped or deleted — a
suite you edited into passing has proved nothing.

## 1. Load context

Read, in order:

1. `AGENTS.md` — the registered workflow, artifact paths and skill rules.
2. `docs/plan/CONTEXT.md` — what the project actually is.
3. The phase file under `docs/phases/` that holds the task.
4. The task block itself, especially its Acceptance Criteria.

Missing artifact → stop and name the skill that produces it: `AGENTS.md` →
`/init`, `docs/plan/CONTEXT.md` → `/plan`, phase file → `/slice`. Never invent
the missing content.

Completion criterion: you can list the task's acceptance criteria verbatim
without having guessed any of them.

## 2. Resolve the invocation

`/check TASK-003` — the one phase file holding that ID.
`/check phase-01` — that file's tasks, in file order, one check file per task.

For a phase sweep, skip every task whose `Implemented` box is unchecked and
report it as not checkable: there is nothing to run. You MAY still check tasks
whose `Reviewed` box is unchecked — review and check are siblings, not a chain.

Completion criterion: a concrete list of tasks, each mapped to its phase file.

## 3. Detect the testing ecosystem

Read the project's own declaration of how it tests — do not assume a framework.
`references/testing.md` carries the detection matrix: which file reveals which
ecosystem, and what to do when nothing declares one.

The project's declared command wins over the tool you would have picked. Name
the file you read to decide, in the check record: "ran the `test` script
declared in the manifest" is evidence, "ran the tests" is not.

Completion criterion: one named file, one exact command, and the reason that
command is the right one for this project.

## 4. Map criteria to tests

For each acceptance criterion, find the existing test that covers it — search
the suite for the function, route or behaviour the criterion names.

A criterion nothing covers needs one of two things, and `references/testing.md`
says which:

- If the criterion is observable by **exercising the feature** (start the app,
  send the request, read the output), exercise it and record the observation.
- If the criterion is about a **branch or a boundary** the exercised path
  cannot reach, write the smallest test that pins it, in the project's own
  framework and file layout.

Completion criterion: every criterion either has an existing test named, or a
planned action from the two branches above.

## 5. Run the narrowest command first

Run the command scoped to this task's area, read the output, then run the
broader suite only if the scoped run passed and the broader suite is quick
enough to be worth it. A wide green suite that never touches this task's code
proves nothing about this task — unrelated green is not evidence.

Record for each run: the exact command, the exit code, and the output lines
that decide pass or fail.

Completion criterion: every criterion has a command output or an observation,
with no criterion left to a summary of the run.

## 6. Analyse honestly

- A failing test is a failure. Record it with output and a root-cause
  hypothesis — a restatement of the failure message is not a hypothesis.
- A skipped, pending, or `todo` test is not a pass.
- A flaky test is not a pass. Re-run it once to judge whether it is flaky;
  either way it is not evidence, and the flakiness is itself a finding to hand
  to `/fix`.
- An error from the harness (a missing dependency, a broken import) is a
  failure of the check, not a pass by default.
- Partial coverage is recorded in Gaps, not rounded up.

Completion criterion: every criterion has a verdict of pass or fail, and you
can justify each one from the recorded output.

## 7. Write the check record

Read `references/result.md` for the exact `docs/checks/TASK-NNN.md` layout.
Write one file per task: Environment, an evidence row per acceptance criterion,
Failures with command and output, Gaps, and the Status verdict.

Failures reference the task they belong to as `TASK-NNN#…` so `/fix` can be
pointed at them. Do not fix anything you found — record it.

Completion criterion: the file exists, every criterion has an evidence row, and
the Status block states an explicit `Tested:` verdict.

## 8. Update task state

Read `references/task-state.md` for the transition this skill owns.

Check `Tested` only when **every** acceptance criterion has passing evidence.
Partial evidence leaves the box at `- [ ]` and goes in Gaps with the reason.
Never clear a box; only `/fix` unchecks.

Completion criterion: the phase file's `Tested` box matches the Status block in
the check record.

## 9. Update CONTEXT.md

Set `## Current Phase` in `docs/plan/CONTEXT.md` to `CHECK` — the field holds
exactly one of the seven step names (`INIT`, `PLAN`, `SLICE`, `EXEC`, `REVIEW`,
`CHECK`, `FIX`), with no task ID and no free text. Change nothing else in that
file.

Completion criterion: `Current Phase` names the step that just ran.

## 10. Report

Tell the user:

- how many criteria were proved, and how many failed;
- each failure with its command and the reference to hand to `/fix`;
- gaps: criteria with no evidence, and why;
- what state changed — the box flipped, or stayed unchecked and why;
- what to run next: `/fix TASK-NNN` when anything failed or a criterion is
  unproved, otherwise the next unreviewed or untested task in the phase.

Completion criterion: the user knows which criteria were proved, which were
not, and the one command to run next.
