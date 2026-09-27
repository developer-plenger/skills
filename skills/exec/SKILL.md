---
name: exec
description: >
  Implement a planned task and check Implemented only when the changed path
  actually runs. Use when the user runs /exec NN-<plan-slug> or /exec
  NN-<plan-slug>/NN-pK, which is the normal form, or /exec TASK-001 when the
  task ID is unambiguous. Reads AGENTS.md and context.md, checks dependencies,
  and reports blocks instead of implementing a task whose dependencies are
  unchecked.
---

# /exec

Implement tasks from a plan's slice files under `specs/NN-<plan-slug>/slice/`. Output is source code; the only markdown you touch is the `Implemented` box in the slice file and the state slot of this plan's line in `context.md`'s `Current Development Status`.

## 1. Load the context, and pick the plan

Read, in this order:

1. `AGENTS.md` — the registered workflow, artifact paths and skill rules.
2. `context.md` — the project's memory, including the plan ledger.
3. The target plan's `spec.md`, opened at the sections a criterion cites.
4. The slice file under `specs/NN-<plan-slug>/slice/NN-pK/tasks.md`.

If `AGENTS.md` is missing, stop and send the user to `/init`. If `context.md` is missing, send them to `/plan`. If the plan has no slices, send them to `/slice`.

**Pick the plan before reading a slice file.** Task IDs restart per plan, so `TASK-001` exists once in every plan folder that has been sliced — an ID alone no longer identifies a task. `/exec NN-<plan-slug>` selects that plan and its first unfinished stage; `/exec NN-<plan-slug>/NN-pK` selects one stage; `/exec NN-<plan-slug>/TASK-001` selects one task. When the argument is a bare `TASK-NNN`, resolve it only if exactly one plan folder contains that ID; otherwise ask which plan, listing the candidates.

**Done when:** you have named the plan, and you have the slice file's task list or know which task(s) the invocation selects.

## 2. Identify the task

Within the chosen plan, `/exec NN-<plan-slug>/NN-pK` selects that stage's tasks in dependency order, and `/exec NN-<plan-slug>/TASK-NNN` selects one task. A plan argument with no stage selects the lowest-numbered stage that still has unchecked tasks, and you say which one you picked before starting.

Confirm the ID appears as a `### TASK-NNN` heading in exactly one file *under that plan folder* — see `references/task-state.md` for the grep and for what to do when it appears twice (stop and report).

**Done when:** the selected task(s), their stage and their slice file are identified, or you stopped with a duplicate-ID report.

## 3. Check dependencies

If the task's `#### Dependencies` lists anything, or its slice's `### BLOCKED BY` names an unlanded task or stage, the task is BLOCKED. Report it and implement the blocker or a different ready task instead — a blocked task cannot be validated even if its code would look right.

**Done when:** every selected task is either unblocked or reported blocked with the specific unchecked dependency named.

## 4. Inspect before writing

Read `references/implementation.md`. Find the code the task touches: search for the existing feature, follow the pattern already in the repo, reuse existing helpers before adding new ones. Never open a guessed file path. On a later plan the feature may already be half-built by an earlier one — search before writing, because re-implementing what plan 01 already shipped is the most common way a new plan wastes its budget.

**Done when:** you can name the files you will change, the pattern you will follow, and the existing helpers you will reuse.

## 5. Implement

Same reference. The description and acceptance criteria are the whole scope; a needed-but-unrequested change becomes a note in the report, not an edit. Smallest coherent change, no drive-by refactors, respect the project's conventions over personal preference.

**Done when:** the change is complete against the description and criteria.

## 6. Validate

Read `references/completion.md`. The changed path must actually run — build it, start it, invoke it, and observe the result. "It compiles" is not done.

**Done when:** you have a command whose output you observed, and that command is recorded in the report.

## 7. Update the state

Read `references/task-state.md` and read the slice file before editing it. Flip only `- [ ] Implemented` to `- [x]` for the task whose code ran. Leave `Reviewed` and `Tested` alone; pre-checking them makes `/review` and `/check` look like they already ran. Reset `Implemented` to unchecked if a later change in this session invalidates the implementation.

**Done when:** the box matches the truth for this task and nothing else in the slice file changed.

## 8. Recommend the check, don't decide it

Say which case you hit:

- **Task needed a test to be trusted** — the acceptance criterion could not be
  observed without one, so you wrote it; still recommend `/check` on the task to
  turn criteria into evidence.
- **Stage finished** — recommend `/check NN-<plan-slug>/NN-pK` to test the stage as a whole.
- **Neither** — some criteria were deliberately left to `/check`; name them and
  recommend running it.

Never silently test nothing; equally, do not run a whole suite to close a
one-task box. Testing is `/check`'s job, and it owns the `Tested` box.

**Done when:** the report names the case and the next command.

## 9. Update `context.md`

Set `Current Phase` to `EXEC` — the field holds exactly one of the seven step names (`INIT`, `PLAN`, `SLICE`, `EXEC`, `REVIEW`, `CHECK`, `FIX`), with no task ID, no plan name, no stage name and no free text; the task, plan and stage belong in your report, not in that field.

Then update the line for **the plan you worked in** in `Current Development Status`: that stage's state, and the repository-wide task count. Condense a finished prefix into a range once the plan has more than roughly eight stages — `p0–p5 ✓ | p6 in progress | p7 pending`.

The line has a summary clause naming what the plan builds. Leave it alone: you flip boxes, you do not restate what the plan delivers. Change nothing else in the file, and never touch another plan's line.

**Done when:** the cursor names the step that ran, this plan's ledger line reflects the boxes you flipped, and no other plan's line changed.

## 10. Report

Use the report format in `references/completion.md`: task ID, files touched, what
you ran and what it printed, criteria met, criteria left for `/check`, blockers.
Then give the next command (`/exec NN-<plan-slug>/TASK-004`,
`/review NN-<plan-slug>/TASK-003`, or `/check NN-<plan-slug>/NN-pK`).

**Done when:** the user can see the evidence for the box you checked and knows
what to run next.
