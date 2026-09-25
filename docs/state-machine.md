# State Machine

Task progress in this pack is three independent flags, not one status field. The flags live in the phase file as checkboxes, and nothing else carries state.

## The three flags

```markdown
### TASK-003 — Login endpoint

- [ ] Implemented
- [ ] Reviewed
- [ ] Tested
```

- `Implemented` — the code exists and runs.
- `Reviewed` — the code has been reviewed and no unresolved finding of Medium severity or higher remains.
- `Tested` — every acceptance criterion has passing evidence.

The three checkboxes are the single source of truth. There is no `status:` field, and no skill may introduce one.

## Why flags beat one status field

A single `status: done` collapses states that are genuinely different, and it forces every consumer to guess what "done" meant. With three flags, the valid intermediate states are visible and nameable:

| Implemented | Reviewed | Tested | Meaning |
| --- | --- | --- | --- |
| no | no | no | Not started |
| yes | no | no | Code written, not yet reviewed or tested |
| yes | yes | no | Implementation and review complete, testing not done |
| yes | no | yes | Tested but not yet reviewed, which is normal because review and check are siblings |
| yes | yes | yes | `DONE` |
| no | yes | no | Invalid. Review requires an implementation to review |
| no | no | yes | Invalid. Testing requires an implementation to test |
| no | yes | yes | Invalid. Both depend on `Implemented` |

The `yes / no / yes` row is the reason the model has to be three flags rather than a chain: a task can be trusted by its tests before anyone has reviewed it, and blocking that ordering would force a fake sequencing the workflow does not have.

`DONE` is derived, never stored:

```text
implemented = true
reviewed    = true
tested      = true
```

is the definition of `DONE`. If any flag is false, the task is not done, whatever the derived label would have been.

## Diagram

```text
                    +--------------+
                    | NOT STARTED  |
                    +------+-------+
                           |
                           v
                    +--------------+
                    | IMPLEMENTED  |
                    +------+-------+
                           |
                    +------+-------+
                    |              |
                    v              v
              +-----------+  +-----------+
              | REVIEWED  |  |  TESTED   |
              +-----+-----+  +-----+-----+
                    |              |
                    +------+-------+
                           v
                    +--------------+
                    |     DONE     |
                    +--------------+
```

The two middle boxes are parallel. Reaching `DONE` requires both, in either order, and neither waits for the other.

## Transitions and their owners

| Transition | Owner | Condition |
| --- | --- | --- |
| `- [ ]` to `- [x]` on `Implemented` | `/exec` | the code actually runs |
| `- [ ]` to `- [x]` on `Reviewed` | `/review` | no unresolved finding of severity Medium or higher remains |
| `- [ ]` to `- [x]` on `Tested` | `/check` | every acceptance criterion has passing evidence |
| `- [x]` to `- [ ]` on any box | `/fix` | the fix invalidated the evidence for that box |

No other skill may write a checkbox. `/review` never checks `Tested`, `/check` never checks `Reviewed`, and neither ever checks `Implemented`.

## Fix reset rule

The contract, quoted verbatim:

> `/fix` resets exactly the boxes whose evidence its change invalidated: a code change always resets Reviewed and Tested; if the fix shows the task was never really implemented, Implemented too. Reset means `- [ ]`.

Two consequences follow. First, a fix can never mark a task as more complete than it was, only less, so the boxes always reflect evidence that still holds. Second, a fix that touches code must force a fresh review and a fresh check, because the evidence the earlier review and check produced no longer describes the current code.

## Blocked rule

A task whose `#### Dependencies` list contains an unchecked task must not be implemented. This applies to the `Implemented` transition specifically: dependencies gate implementation, not review or check. A task that is already implemented stays reviewable and testable even if a sibling it depends on is reset by a fix, but the reset that follows may reopen this task's own boxes.

## State is in the file

Because the flags are checkboxes in `docs/phases/phase-NN-<slug>.md`:

- progress is visible in a diff, in a code review, and in any editor;
- no external database or tool is required to read the current state;
- `/review`, `/check`, and `/fix` can all be run by different sessions without coordination;
- a human can correct a box by hand, and the next skill will respect the correction.

## Iteration

```text
exec -> (review || check) -> fix -> (review || check) -> ...
```

The loop exits for a task when all three boxes are checked. The loop exits for a phase when every task in the phase file is `DONE`, at which point `/slice` produces the next phase.
