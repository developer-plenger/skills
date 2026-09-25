# Dependencies and ordering

Dependencies live at two levels, and each level has its own block in the phase
file.

## Task level — inside one phase's task list

`#### Dependencies` lists the sibling tasks that must be done before this task
starts. The dependency is task-level when the code is not there yet: task B
edits the function task A creates, or A establishes the schema B reads. Both
tasks should also be in the same slice — if they cannot both be verified by the
slice's one objective, they belong to different slices.

A task with an unchecked dependency is **BLOCKED**. `/exec` must not implement
it; it implements the blocker or a different task and reports the block.

## Phase level — across the plan

The `## Dependencies` section holds two lists:

```markdown
## Dependencies

### BLOCKED BY

- TASK-001

### BLOCKS

- Phase 03
```

- `### BLOCKED BY` — what must land first. Either `TASK-NNN` (a task in an earlier
  phase whose output this phase consumes) or `Phase NN`. Use `- None` for the
  first phase.
- `### BLOCKS` — the phases this one must finish before. Use `- None`, or write
  `Phase 03` and later, as in the concept.
- Both blocks are always present, never omitted. An absent block reads as "not
  considered"; `- None` reads as "considered, nothing there".
- They are one relationship written twice: if phase 03 lists `Phase 02` in BLOCKED
  BY, then phase 02's BLOCKS lists `Phase 03`. Check both directions before finishing.

## Ordering phases topologically

1. Treat each phase as a node and each BLOCKED BY edge as an arrow.
2. Emit root phases (no blockers) first, then repeatedly phases whose blockers
   are all already emitted.
3. Break ties — several phases ready at once — by **risk and unknowns first**.
   The tracer bullet wins by construction, but among the rest put the phase
   with the unfamiliar integration, the unproven technology, or the heaviest
   external dependency earlier. Cheap-but-certain work can wait; it does not
   get more expensive by being late, while uncertainty does.
4. Renumber nothing. If ordering changes, move whole files and rewrite the
   cross-references, or leave the numbers and let the dependency blocks carry
   the order — `/exec` follows dependencies, not file order.

## Cycles

A cycle means the plan cannot be executed as written. Detect it before emitting:
after drawing edges, walk from each phase following BLOCKED BY; if you return to
the start, you have a cycle.

Report it — do not emit a broken plan and do not "fix" it by quietly dropping an
edge. Give the user the concrete loop and the reason each edge exists:

```
Cycle: phase-02 → phase-04 → phase-02
phase-02 needs the API client from phase-04.
phase-04 needs the schema from phase-02.
Options: (a) ship a stub client in phase-02, splitting the edge;
         (b) move the schema task into phase-04 and start from it;
         (c) merge phase-02 and phase-04 into one slice.
```

Then let the user choose. A cycle in the dependency graph is usually a genuine
sign the slicing is wrong — most often two slices that were cut by layer.

## Real dependency vs. conventional order

Only architectural necessity makes a dependency real: B cannot be built or
verified without A's output. Everything else is convention — alphabetical
grouping, "we usually do auth first", "the dashboard feels later", a preference
about where the diff lands.

Conventional orderings do not go in BLOCKED BY. Listing them gives `/exec` a
false block, so it skips a task that was perfectly startable and reports a
blocker that does not exist. When two phases genuinely have no edge between
them, leave both blocks at `- None` and let the user or `/exec` pick; note the
suggested order in your report instead.
