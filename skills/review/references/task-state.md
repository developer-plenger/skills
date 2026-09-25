# Task State — Review

The box `/review` owns, when it may be flipped, and the rules that keep the
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

Flip `- [ ] Reviewed` to `- [x]` only when both hold:

1. Every finding in `docs/reviews/TASK-NNN.md` is `Low`, or is `Fixed` **and
   re-confirmed by this review**.
2. No unresolved finding is of severity Medium or higher.

Otherwise leave the box at `- [ ]` and name the blocking findings in your
report to the user, by ID and severity.

A finding that `/fix` reported as fixed but this review has not re-confirmed
counts as Open here. Whether the fix works is exactly what the `Reviewed` box
claims knowledge of, so an unverified fix cannot support it.

Record the same decision in the review doc's Status block: `Reviewed: true` or
`Reviewed: false`. The two must agree; the phase file is the source of truth
for state, the review doc for reasoning.

## Never clear a box

`/review` does not uncheck anything, even when it finds that a previous review
was wrong. Disagreement is expressed by writing findings and leaving (or
leaving unset) the box — the mechanism that clears it is `/fix` recording a
change, which is traceable.

## Locating a task

`TASK-NNN` lives in exactly one file under `docs/phases/`. Find it by grep:

```
grep -rn "^### TASK-003" docs/phases
```

One hit, in a `### TASK-003 — …` heading: proceed. **Two or more hits: stop and
report.** A duplicated ID means review and check artifacts point at one of several
tasks, and picking one silently writes state into the wrong place. The fix is a
`/slice` amendment — renumber the duplicate — not a guess by `/review`.

The `^### ` anchor is load-bearing, not decoration: an unanchored grep also
matches every `#### Dependencies` edge and `### BLOCKED BY` reference, so a
well-formed plan returns several hits for one task and the rule above would halt
a plan with nothing wrong with it. Only a task heading defines a task.

## Phase sweep

Phase IDs come from the filename: `phase-01-foundation.md` is `phase-01`. Both
`/review TASK-003` and `/review phase-01` resolve through the same lookup.

`/review phase-01` walks the tasks in the order they appear in that file and
writes one review file per task.

Skip every task whose `Implemented` box is unchecked: there is no code to
review, and reviewing a description produces findings about nothing. Report
each skipped task by ID, as not reviewable yet, with the command that would
make it reviewable (`/exec TASK-NNN`).

The sweep is not atomic. If a task's review ends with `Reviewed: false`, keep
going with the remaining tasks — the user needs the whole picture before
deciding what to fix. Report every verdict at the end.

## Stale Reviewed boxes

The `Reviewed` box asserts one thing: as of some review, the code had no
unresolved Medium-or-higher finding. A later change to the code invalidates
that assertion — the review judged code that no longer exists.

`/review` does not chase this on its own; clearing is `/fix`'s job. But when
writing a review, or when a phase sweep finds a task marked `Reviewed` with
code changes after the review file's date, say so in the report and record in
**Verification** what you reviewed relative to those changes.
