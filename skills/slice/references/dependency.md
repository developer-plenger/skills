# Dependencies and ordering

Dependencies live at two levels, and each level has its own block in the slice file.

## Task level — inside one stage's task list

`#### Dependencies` lists the sibling tasks that must be done before this task
starts. The dependency is task-level when the code is not there yet: task B
edits the function task A creates, or A establishes the schema B reads. Both
tasks should also be in the same stage — if they cannot both be verified by the
stage's one objective, they belong to different stages.

A task with an unchecked dependency is **BLOCKED**. `/exec` must not implement
it; it implements the blocker or a different task and reports the block.

Task IDs restart per plan, so a `#### Dependencies` entry naming `TASK-002` means
`TASK-002` **in this plan**. A dependency on a task from an earlier plan is not
expressible as a bare ID: name the plan and stage instead — `plan-01/03-p2` — so
the reader knows which document to open.

The `## Dependencies` section holds two lists:

```markdown
## Dependencies

### BLOCKED BY

- TASK-001

### BLOCKS

- p3
```

- `### BLOCKED BY` — what must land first. Within this plan: `TASK-NNN` (a task in
  an earlier stage whose output this stage consumes) or a stage name (`p2` for
  `02-p2`). Use `- None` for this plan's first stage.
- `### BLOCKS` — the stages this one must finish before. Use `- None`, or name
  the next stage folders in this plan.
- Both blocks are always present, never omitted. An absent block reads as "not
  considered"; `- None` reads as "considered, nothing there".
- They are one relationship written twice: if `02-p1` lists `p0` in BLOCKED BY,
  then `01-p0`'s BLOCKS lists `p1`. Check both directions before finishing.

Stage names here are short (`p0`, `p3`) because the plan prefix is the file's own
path — inside `specs/02-monthly-budgets/slice/03-p2/tasks.md`, `p0` can only mean
that plan's `01-p0`.

## Ordering stages topologically

1. Treat each stage as a node and each BLOCKED BY edge as an arrow.
2. Emit root stages (no blockers) first, then repeatedly stages whose blockers
   are all already emitted.
3. Break ties — several stages ready at once — by **risk and unknowns first**.
   The tracer bullet wins by construction, but among the rest put the stage
   with the unfamiliar integration, the unproven technology, or the heaviest
   external dependency earlier. Cheap-but-certain work can wait; it does not
   get more expensive by being late, while uncertainty does.
4. Renumber nothing. If ordering changes, move whole folders and rewrite the
   cross-references, or leave the numbers and let the dependency blocks carry
   the order — `/exec` follows dependencies, not folder order.

## Cycles

A cycle means the plan cannot be executed as written. Detect it before emitting:
after drawing edges, walk from each stage following BLOCKED BY; if you return to
the start, you have a cycle.

Report it — do not emit a broken plan and do not "fix" it by quietly dropping an
edge. Give the user the concrete loop and the reason each edge exists:

```
Cycle: 02-p1 → 04-p3 → 02-p1
02-p1 needs the API client from 04-p3.
04-p3 needs the schema from 02-p1.
Options: (a) ship a stub client in 02-p1, splitting the edge;
         (b) move the schema task into 04-p3 and start from it;
         (c) merge 02-p1 and 04-p3 into one stage.
```

Then let the user choose. A cycle in the dependency graph is usually a genuine
sign the slicing is wrong — most often two stages that were cut by layer.

## Real dependency vs. conventional order

Only architectural necessity makes a dependency real: B cannot be built or
verified without A's output. Everything else is convention — alphabetical
grouping, "we usually do auth first", "the dashboard feels later", a preference
about where the diff lands.

Conventional orderings do not go in BLOCKED BY. Listing them gives `/exec` a
false block, so it skips a task that was perfectly startable and reports a
blocker that does not exist. When two stages genuinely have no edge between
them, leave both blocks at `- None` and let the user or `/exec` pick; note the
suggested order in your report instead.

## Dependencies may point at an earlier plan

A later plan builds on work an earlier plan delivered, so its stages can and often
do depend on it. Because task and stage IDs restart per plan, the reference has to
name the plan:

```markdown
### BLOCKED BY

- plan-01/03-p2
- plan-01/03-p2/TASK-007
```

`plan-01/03-p2` reads as "the stage at `specs/01-initial-build/slice/03-p2/`".
Naming it is how a new feature says "this builds on the exports screen plan 01
already shipped". It is a real edge and belongs here.

What does not belong here is a dependency on a bare feature name. `- CSV export`
is not a stage and `/exec` cannot resolve it; write the stage that delivered it,
qualified with its plan, or `- None` when the code the new stage needs is already
on disk and nothing has to land first.
