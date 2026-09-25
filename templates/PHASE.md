# Phase {{NN}} — {{Phase Title}}

## Objective

{{What this phase achieves, in one paragraph.}}

## Vertical Slice

{{The end-to-end capability the user can exercise when this phase is complete. Write it as something the user can do, not as layers of infrastructure.}}

## Tracer Bullet

{{The thinnest path through the whole stack that proves the slice works end to end, and which task delivers it.}}

## Dependencies

### BLOCKED BY

- {{TASK-NNN, or "None"}}

### BLOCKS

- {{Phase NN+1, or "None"}}

## Tasks

The three checkboxes below are the only state carrier for a task. Never add a `status:` field. `Implemented` is flipped by `/exec`, `Reviewed` by `/review`, `Tested` by `/check`. `DONE` is derived when all three are checked, never stored. `/fix` resets a box to `- [ ]` when its evidence is invalidated.

### TASK-{{NNN}} — {{Task Title}}

- [ ] Implemented
- [ ] Reviewed
- [ ] Tested

#### Description

{{What to build, and the boundary of the task. Name the files or modules it is expected to touch when they are already known.}}

#### Acceptance Criteria

- {{A verifiable condition. Each one must be checkable by a test or a direct observation.}}

#### Dependencies

- {{TASK-NNN, or "None"}}
