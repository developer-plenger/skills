# Task State — Check

The box `/check` owns, when it may be flipped, and the rules that keep the
three skills from disagreeing about task state.

## Where state lives

Task state is the three checkboxes in the task block of
`docs/phases/phase-NN-<slug>.md`:

```markdown
### TASK-003 — Login endpoint

- [ ] Implemented
- [ ] Reviewed
- [ ] Tested
```

There is no `status:` field, no YAML block, no separate state file. If you find
one, it is stale and the checkboxes are the truth.

`DONE` is **derived**, never stored: all three boxes checked. Never write the
word `DONE` into a phase file.

## Who may flip what

One owner per box. A skill may check only the box it owns, and only after
producing the evidence that box asserts.

| Box | Flipped by | Meaning |
|---|---|---|
| `Implemented` | `/exec` | The code exists and actually runs. |
| `Reviewed` | `/review` | No unresolved finding of severity Medium or higher. |
| `Tested` | `/check` | Every acceptance criterion has passing evidence. |

**Only `/fix` may uncheck a box** — and `/fix` never checks one. `/exec`,
`/review` and `/check` check; `/fix` unchecks and nothing else.

## The transition this skill owns

Flip `- [ ] Tested` to `- [x]` only when **every** acceptance criterion in the
task block has passing evidence in `docs/checks/TASK-NNN.md`.

The bar is all-or-nothing:

- One criterion unproved → the box stays `- [ ]`, and that criterion is named
  in **Gaps** with its reason.
- One criterion failed → the box stays `- [ ]`, and the failure is recorded
  with its command, output and root-cause hypothesis for `/fix`.
- Criteria proved only by running the app by hand, with no test, still count —
  the criterion is what must be proved, not a test's existence. Say in the
  record that the evidence is manual.

Record the same decision in the check doc's Status block: `Tested: true` or
`Tested: false`. The two must agree; the phase file is the source of truth for
state, the check doc for evidence.

## Never clear a box

`/check` does not uncheck anything. When a check finds evidence that an earlier
`Tested: true` was wrong — the criterion no longer holds, or it never did — the
box is still `/fix`'s to clear once the code changes. `/check` writes the
failure and reports it.

## Staleness

The `Tested` box asserts: as of some check, every acceptance criterion passed
against the code as it stood then. Any later code change invalidates that
assertion — whatever was proved, it was proved about code that no longer
exists.

Staleness is detected by other skills:

- `/fix` resets `Tested` when its change touched code (see `/fix`'s own
  `task-state.md`).
- `/check` itself may notice a stale box during a phase sweep — code changed
  after the check file's date — and should say so in the report, re-running
  that task's criteria if asked.

Do not treat a stale `Tested: true` as licence to skip re-running. When in
doubt, re-run: the cost is a command, the alternative is a false claim.

## Locating a task

`TASK-NNN` lives in exactly one file under `docs/phases/`. Find it by grep:

```
grep -rn "^### TASK-003" docs/phases
```

One hit, in a `### TASK-003 — …` heading: proceed. **Two or more hits: stop and
report.** A duplicated ID means review and check artifacts point at one of several
tasks, and picking one silently writes state into the wrong place. The fix is a
`/slice` amendment — renumber the duplicate — not a guess by `/check`.

The `^### ` anchor is load-bearing, not decoration: an unanchored grep also
matches every `#### Dependencies` edge and `### BLOCKED BY` reference, so a
well-formed plan returns several hits for one task and the rule above would halt
a plan with nothing wrong with it. Only a task heading defines a task.

## Phase sweep

Phase IDs come from the filename: `phase-01-foundation.md` is `phase-01`.

`/check phase-01` walks the tasks in the order they appear in that file and
writes one check file per task.

- Skip every task whose `Implemented` box is unchecked: there is nothing to
  run. Report each skipped task by ID with the command that would make it
  checkable (`/exec TASK-NNN`).
- A task whose `Reviewed` box is unchecked is still checkable. Review and check
  are siblings of exec, not a chain — nothing about a task's testability
  depends on whether it has been reviewed.
- The sweep is not atomic. Continue past a failing task: one task's failure
  does not make the next task's criteria unprovable, and the user needs the
  whole picture.
- For each task, run the narrowest command covering that task, so a failure in
  one task's output does not contaminate the next task's evidence.
