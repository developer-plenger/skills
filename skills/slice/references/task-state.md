# Phase files and task state

## Filenames

`docs/phases/phase-NN-<slug>.md`, `NN` starting at `01`, the slug
lowercased-hyphenated from the phase objective — `phase-03-login-endpoint.md`,
not `phase-03-login_endpoint.md` or `phase-3-login.md`. Zero-pad to two digits so
lexical order is execution order.

Adding a phase appends the next free number. **Never renumber existing phases** —
reviews, checks, fixes and `CONTEXT.md` all refer to them by filename, so a
renumber silently orphans every reference.

## Exact file shape

```markdown
# Phase 02 — Authentication

## Objective

## Vertical Slice

## Tracer Bullet

## Dependencies

### BLOCKED BY

- TASK-001

### BLOCKS

- Phase 03

## Tasks

### TASK-003 — Login endpoint

- [ ] Implemented
- [ ] Reviewed
- [ ] Tested

#### Description

#### Acceptance Criteria

- …

#### Dependencies

- TASK-001
```

Heading levels are load-bearing: `#` phase, `##` sections, `###` tasks and
dependency sub-blocks, `####` task fields. `/exec` locates a task by grepping
`### TASK-NNN`, so a task written with a different level will be missed.

## Task numbering

`TASK-NNN`, zero-padded to three, **global and continuous across all phases** —
`TASK-001` is the first task ever created in the project and `TASK-004` never
repeats. Before writing, find the highest ID already used:

```
grep -rhoE 'TASK-[0-9]{3}' docs/phases | sort | tail -1
```

The three-digit width is load-bearing: `sort` compares text, so the command is
only correct while every ID has the same number of digits. A stray `TASK-9`
hand-typed next to padded IDs sorts *after* `TASK-010` and becomes the printed
answer, so pin the width in the pattern and let a violation fail to match rather
than mis-order. `-u` is gone because it never contributed: the defect was
comparison order, and deduping IDs does not pick a maximum. Widen the padding
rule and this pattern together if a project ever reaches `TASK-1000` — a
four-digit ID matches only its first three digits (`TASK-100`), so the command
prints a wrong answer rather than failing loudly.

Continue from there. Never reuse an ID, never skip one, never restart at 001 in
a new phase: IDs appear in review and check filenames and inside task
dependencies, so a collision points at the wrong task. If a task is removed,
its ID retires — do not fill the hole.

## Task sizing

One task = one coherent change with its own acceptance criteria, independent of
its siblings. That means:

- It can be described without "and" joining two unrelated outcomes.
- Its criteria can be checked without another task in the phase being done,
  apart from the ones in its own `#### Dependencies`.
- It fits a single focused session. If the description needs sub-headings to
  stay clear, it is two tasks.

Tasks inside a phase carry no ordering of their own beyond `#### Dependencies`;
shared helpers needed by several tasks are their own task, depended on by each.

## Acceptance criteria

Criteria come from the spec requirement the task implements (§8 and §19), not
from the implementation the author has in mind. Each criterion must be
observable from outside the code — something a person or a test can check
without reading the diff. Rewrite the requirement in the imperative and split it
until each line passes this bar:

- **Observable**: names an input and an expected result. "Handle errors
  properly" fails; "submitting an empty email returns 400 with the field name"
  passes.
- **Falsifiable**: a stub implementation fails it. If the criterion holds on an
  empty function, it is not a criterion.
- **Bounded**: one behaviour per bullet, no "and also".
- **Spec-traceable**: you can point at the §8 requirement it comes from; if you
  cannot, either the criterion is invented or the spec is missing a requirement
  — report the latter rather than absorbing it.

Include the boundary or error case the requirement implies, and prefer a concrete
example over an abstraction: "login with a wrong password returns 401 and does
not create a session" beats "authentication is secure". Do not write testing
steps here — `/check` turns criteria into evidence; these say *what must be true*.

## Why three boxes and not a `status:` field

Three independent booleans because the states are independently true: code that
runs but is unreviewed and untested is a normal, useful position in the
middle of a day. A single `status` cannot hold it without inventing a fourth
value for every combination, and the first person in a hurry picks `done` because
that is the only one that closes the ticket.

The three boxes are also the whole state. There is no `status:` field anywhere in
the file, and none is to be added — **`DONE` is derived from all three being
checked, never stored**. A stored `DONE` is a second source of truth that will
disagree with the boxes the moment someone checks one.

## Who may flip which box

The boxes have exactly one owner each. `/slice` creates every task with all
three unchecked and never flips them afterwards — it may amend the description
or criteria of a task that has not been started, and must report a task it
changed, but an implemented task's state belongs to the skills below.

| Box | Flipped by | Flipped only when |
| --- | --- | --- |
| `Implemented` | `/exec` | the changed path actually runs — not when it compiles |
| `Reviewed` | `/review` | no unresolved finding of severity Medium or higher remains |
| `Tested` | `/check` | every acceptance criterion has passing evidence |

Reset means writing `- [ ]` again. `/fix` resets exactly the boxes its change
invalidated: a code change always resets Reviewed and Tested, and resets
Implemented too if the fix shows the task was never really implemented.
