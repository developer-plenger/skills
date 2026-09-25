# Task State — Fix

The reset rule `/fix` owns, and the rules that keep the three skills from
disagreeing about task state.

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

## The reset rule

A checkbox states something about the code as it stood when the skill that
checked it did its work. When `/fix` changes the code, those statements become
claims about code that no longer exists, so the boxes must go back to `- [ ]`.

| What the fix changed | `Implemented` | `Reviewed` | `Tested` |
|---|---|---|---|
| **Source code** | left as is | **reset** | **reset** |
| **Observation that the task was never really implemented** | **reset** | **reset** | **reset** |
| **Documentation or comments only** | left as is | left as is | left as is |
| **Tests only** | left as is | left as is | **reset** |
| **The review or check record itself** | left as is | left as is | left as is |

- **A code change always resets `Reviewed` and `Tested`.** Both boxes' evidence
  was gathered against the old code: the review judged it, the check ran
  against it. Neither survives the edit.
- **Reset `Implemented` too when the finding showed the task was never really
  implemented** — a handler that was a stub, a path that never executed, a
  criterion silently skipped. `/exec`'s box means "the code exists and runs";
  the fix just proved it did not. This is the one case where a finding about
  behaviour also invalidates the implementation claim.
- **A fix that changed only documentation or tests resets only what it
  invalidated**, and the fix record says which boxes and why. A comment-only
  change does not invalidate a review of the logic; a test change does
  invalidate the `Tested` evidence, because the evidence is now different
  evidence.
- Reset means writing `- [ ]` over the existing `- [x]`. There is no partial
  state and no "reset pending" marker.

Record the resets in the fix file's `## Result` section, one line per box, with
the reason that box specifically was invalidated — including which box you left
checked that a reader might expect you to reset.

## `/fix` never checks a box

`/fix` only unchecks. Even when the fix is verified, the boxes belong to the
skills that own them:

```text
/fix changes code  →  resets Reviewed and Tested
/review re-reads   →  checks Reviewed when no Medium+ finding remains
/check  re-runs    →  checks Tested when every criterion passes
```

This is why a fix ends by sending the task back to both. A fix that checked its
own boxes would be marking its own homework, and the review doc's re-confirmed
finding status — the thing that lets the box flip — would never be produced.

## After a fix, the task re-enters both flows

`/review` and `/check` are siblings, not a chain. A code change stales both
bodies of evidence, so both must run again:

```text
/fix TASK-003
  ↓
/review TASK-003   →  re-confirms findings, flips Reviewed if clean
/check  TASK-003   →  re-runs criteria, flips Tested if all pass
```

In either order. Report both to the user; do not describe the task as done when
only one has run.

## Unfixed findings stay as they are

`/fix TASK-003#FINDING-002` resets boxes based on what *that* fix changed. When
other findings on the same task remain Open, say so in `## Result` and in the
report: the task's `Reviewed` box would stay `- [ ]` on the next pass anyway,
and the user needs to know that before running `/review`.

## Locating a task

`TASK-NNN` lives in exactly one file under `docs/phases/`. Find it by grep:

```
grep -rn "^### TASK-003" docs/phases
```

One hit, in a `### TASK-003 — …` heading: proceed. **Two or more hits: stop and
report.** A duplicated ID means review and check artifacts point at one of several
tasks, and picking one silently writes state into the wrong place. The fix is a
`/slice` amendment — renumber the duplicate — not a guess by `/fix`.

The `^### ` anchor is load-bearing, not decoration: an unanchored grep also
matches every `#### Dependencies` edge and `### BLOCKED BY` reference, so a
well-formed plan returns several hits for one task and the rule above would halt
a plan with nothing wrong with it. Only a task heading defines a task.

## Phase sweep

Phase IDs come from the filename: `phase-01-foundation.md` is `phase-01`.

`/fix phase-01` collects every task in the phase with an open finding or a
recorded failure, then handles them **one task at a time**, and within a task
one finding at a time.

- Re-read the phase file's task blocks at the start to build the list; the file
  may have changed since the finding was written.
- Never batch edits across tasks: a sweep that edits three files in one pass
  produces a fix record no reader can trace back to individual findings.
- Reset each task's boxes as its own fixes land, and record them in that task's
  fix file — not in a phase-level summary.
- Report per task at the end: which findings were remediated, which were not,
  which boxes reset.
