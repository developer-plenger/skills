# Task state for /exec

## The three boxes

A task's state is the three checkboxes in its phase file — nothing else. There is
no `status:` field, and adding one is not an option: it would be a second source
of truth that disagrees with the boxes the moment anyone checks one.

```markdown
- [ ] Implemented
- [ ] Reviewed
- [ ] Tested
```

`DONE` is derived — all three checked — and never stored.

| Box | Owner | Flipped only when |
| --- | --- | --- |
| `Implemented` | `/exec` | the changed path actually runs — not when it compiles |
| `Reviewed` | `/review` | no unresolved finding of severity Medium or higher remains |
| `Tested` | `/check` | every acceptance criterion has passing evidence |

`/exec` owns `Implemented` and touches nothing else. Do not check `Reviewed` or
`Tested` "while you are in the file" — even if you wrote tests or think the code
is obviously fine. Those boxes assert that another skill did the work, and
pre-checking them makes `/review` and `/check` look like they ran.

## Locating a task

`TASK-NNN` lives in exactly one file under `docs/phases/`. Find it by grep:

```
grep -rn "^### TASK-003" docs/phases
```

One hit, in a `### TASK-003 — …` heading: proceed. **Two or more hits: stop and
report.** A duplicated ID means review and check artifacts point at one of several
tasks, and picking one silently writes state into the wrong place. The fix is a
`/slice` amendment — renumber the duplicate — not a guess by `/exec`.

The `^### ` anchor is load-bearing, not decoration: an unanchored grep also
matches every `#### Dependencies` edge and `### BLOCKED BY` reference, so a
well-formed plan returns several hits for one task and the rule above would halt
a plan with nothing wrong with it. Only a task heading defines a task.

## Flipping Implemented

1. Implement the task, validate it (see `completion.md`), and watch it pass.
2. Edit the target line in place: `- [ ] Implemented` becomes `- [x] Implemented`.
3. Change nothing else in the file — not Reviewed, not Tested, not whitespace,
   not the description, not criteria to match what you built. A criterion that
   turned out wrong is a finding to report, not text to quietly improve.

If a later change invalidates the implementation, **reset `Implemented` to `- [ ]`**.
Your own work breaks a task you already checked; so does discovering mid-task
that the code does not exercise the path it claims. Reset it rather than leaving
a box checked over broken code — and note in the report whether the reset also
invalidates Reviewed/Tested (it always does; the fixing skill performs that part).

Ambiguity is not a reason to leave it half-set: the box is checked when the
path runs and unchecked when it does not. "Almost working" is unchecked.

## `/exec phase-01`

Walk the phase's tasks in dependency order, one at a time:

1. Read the phase file and build the order from `#### Dependencies` — a task
   whose blockers are all checked comes before it. Ties: keep file order.
2. For each task: if any dependency is unchecked, **skip it** and continue to the
   next ready task. Never reorder the list to unblock yourself, and never
   implement a blocked task "partially" — record the block and move on.
3. Finish the task: implement, validate, flip `Implemented`, report to the user
   (format in `completion.md`). One task at a time, with its report, so the user
   can stop you between tasks.
4. Tasks skipped as blocked get reported at the end with the specific unchecked
   dependency that held them. If every remaining task is blocked, stop and report;
   do not implement blockers outside their own task's description.
5. When the phase's tasks are all checked (or all reachable ones are), report the
   phase summary and say what `/review` and `/check` should run on next.
