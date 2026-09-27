# Slice {{NN-pK}} — {{Stage Title}}

<!-- Lives at specs/NN-<plan-slug>/slice/NN-pK/tasks.md, inside one plan
     folder. Stage numbering restarts in every plan: this may be plan-02's 01-p0.
     Task IDs restart too — TASK-001 exists once per plan folder. -->

## Objective

{{What this development stage of the plan achieves, in one paragraph. Carry any deferrable open question inherited from the plan spec's §17 here, verbatim, so `/exec` sees the unknown.}}

## Vertical Slice

{{The end-to-end capability the user can exercise when this stage is complete, naming the §8 requirements of THIS PLAN it satisfies. Write it as something the user can do, not as layers of infrastructure.}}

## Tracer Bullet

{{The thinnest path through the whole stack that proves this stage works end to end, and which task delivers it. On a later plan this is the thinnest path the plan's feature travels, not a new whole-product spike.}}

## Dependencies

### BLOCKED BY

- {{TASK-NNN within this plan, a stage name like "p1", a stage from an earlier
  plan as "plan-01/03-p2", or "None"}}

### BLOCKS

- {{a slice name like "p3", or "None"}}

## Tasks

The three checkboxes below are the only state carrier for a task. Never add a `status:` field. `Implemented` is flipped by `/exec`, `Reviewed` by `/review`, `Tested` by `/check`. `DONE` is derived when all three are checked, never stored. `/fix` resets a box to `- [ ]` when its evidence is invalidated.

### TASK-{{NNN}} — {{Task Title}}

- [ ] Implemented
- [ ] Reviewed
- [ ] Tested

#### Description

{{What to build, and the boundary of the task. Name the files or modules it is expected to touch when they are already known. Check first whether an earlier plan already shipped part of this — reuse it rather than rebuilding.}}

#### Acceptance Criteria

- {{A verifiable condition. Each one must be checkable by a test or a direct observation.}}

#### Dependencies

- {{TASK-NNN, or "None"}}
