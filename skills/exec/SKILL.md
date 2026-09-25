---
name: exec
description: >
  Implement a planned task and check Implemented only when the changed path
  actually runs. Use when the user runs /exec TASK-001 or /exec phase-01, asks to
  implement a task, build the next task, work through a phase file, or validate a
  change. Reads AGENTS.md and CONTEXT.md, checks dependencies, and reports blocks
  instead of implementing a task whose dependencies are unchecked.
---

# /exec

Implement tasks from `docs/phases/`. Output is source code; the only markdown
you touch is the `Implemented` box in the phase file and `docs/plan/CONTEXT.md`.

## 1. Load the context

Read, in this order:

1. `AGENTS.md` — project rules, conventions, and the registered workflow.
2. `docs/plan/CONTEXT.md` — the one-page summary; it tells you what exists.
3. The phase file you were pointed at, under `docs/phases/`.

If `AGENTS.md` is missing, stop and send the user to `/init`. If no phase file
matches the argument, stop and send them to `/slice`. Never invent a task or a
phase — implementing against content you made up is unreviewable.

`docs/plan/SPEC.md` is optional context; open the specific section a criterion
cites when you need the requirement behind it, not the whole file.

**Done when:** you have the phase file's task list and know which task(s) the
invocation selects.

## 2. Identify the task

`/exec TASK-003` selects one task. `/exec phase-01` selects the phase's tasks in
dependency order. Either way, confirm the ID appears as a `### TASK-NNN` heading
in exactly one file — see `references/task-state.md` for the grep and for what to
do when it appears twice (stop and report).

**Done when:** the selected task(s) and their file are identified, or you stopped
with a duplicate-ID report.

## 3. Check dependencies

If the task's `#### Dependencies` lists anything, or its phase's `### BLOCKED BY`
names an unlanded task or phase, the task is BLOCKED. Report it and implement the
blocker or a different ready task instead — a blocked task cannot be validated
even if its code would look right.

**Done when:** every selected task is either unblocked or reported blocked with
the specific unchecked dependency named.

## 4. Inspect before writing

Read `references/implementation.md`. Find the code the task touches: search for
the existing feature, follow the pattern already in the repo, reuse existing
helpers before adding new ones. Never open a guessed file path.

**Done when:** you can name the files you will change, the pattern you will
follow, and the existing helpers you will reuse.

## 5. Implement

Same reference. The description and acceptance criteria are the whole scope; a
needed-but-unrequested change becomes a note in the report, not an edit.
Smallest coherent change, no drive-by refactors, respect the project's
conventions over personal preference.

**Done when:** the change is complete against the description and criteria.

## 6. Validate

Read `references/completion.md`. The changed path must actually run — build it,
start it, invoke it, and observe the result. "It compiles" is not done.

**Done when:** you have a command whose output you observed, and that command is
recorded in the report.

## 7. Update the state

Read `references/task-state.md` and read the phase file before editing it. Flip
only `- [ ] Implemented` to `- [x]` for the task whose code ran. Leave `Reviewed`
and `Tested` alone; pre-checking them makes `/review` and `/check` look like they
already ran. Reset `Implemented` to unchecked if a later change in this session
invalidates the implementation.

**Done when:** the box matches the truth for this task and nothing else in the
phase file changed.

## 8. Recommend the check, don't decide it

Say which case you hit:

- **Task needed a test to be trusted** — the acceptance criterion could not be
  observed without one, so you wrote it; still recommend `/check` on the task to
  turn criteria into evidence.
- **Slice or phase finished** — recommend `/check phase-NN` to test the slice as
  a whole.
- **Neither** — some criteria were deliberately left to `/check`; name them and
  recommend running it.

Never silently test nothing; equally, do not run a whole suite to close a
one-task box. Testing is `/check`'s job, and it owns the `Tested` box.

**Done when:** the report names the case and the next command.

## 9. Update `docs/plan/CONTEXT.md`

Set `Current Phase` in `docs/plan/CONTEXT.md` to `EXEC` — the field holds exactly
one of the seven step names (`INIT`, `PLAN`, `SLICE`, `EXEC`, `REVIEW`, `CHECK`,
`FIX`), with no task ID and no free text. Then rewrite `Current Development
Status` as the short phase list with each phase's state — max ~6 lines; condense
older phases into a range when the list grows past that. The phase you worked in
belongs in that status list and in your report, not in `Current Phase`: a value
like `phase-01` breaks every reader that matches the field against the enum.

**Done when:** `Current Phase` names the step that just ran, and the status list
reflects the tasks you closed.

## 10. Report

Use the report format in `references/completion.md`: task ID, files touched, what
you ran and what it printed, criteria met, criteria left for `/check`, blockers.
Then give the next command (`/exec TASK-004`, `/review TASK-003`, or
`/check phase-01`).

**Done when:** the user can see the evidence for the box you checked and knows
what to run next.
