# Workflow

The `developer-plenger` pack is one workflow, not seven independent prompts. Each skill consumes the artifact the previous one produced and leaves exactly one artifact behind. Nothing important lives in the chat log. One field is shared: `Current Phase` in `context.md`, the workflow's cursor, which every skill advances.

## One plan, one folder

**Every `/plan` run creates its own plan folder.** `specs/01-<plan-slug>/` is the first plan, `specs/02-<plan-slug>/` the second, and so on. Each folder is self-contained: a `spec.md` stating what that plan builds, a `slice/` folder holding its development stages, and the reviews, checks and fixes of the work it produced.

```text
specs/
  01-initial-build/            the first /plan — the initial build
    spec.md                    what plan 01 builds
    slice/
      01-p0/tasks.md           its first stage (the tracer bullet)
      02-p1/tasks.md
      03-p2/tasks.md
    reviews/TASK-003.md
    checks/TASK-003.md
    fixes/TASK-003.md
  02-monthly-budgets/          the second /plan — a feature
    spec.md                    what plan 02 builds, and only that
    slice/
      01-p0/tasks.md           its own p0 — stage numbering restarts per plan
      02-p1/tasks.md
  03-csv-export/
    spec.md
    slice/
      01-p0/tasks.md           its own p0 again
      02-p1/tasks.md
```

Three rules make this structure work:

- **Plan folders are append-only.** A later `/plan` never edits an earlier plan's `spec.md`, and never renumbers a folder. Plans are history: `plan-03/spec.md` says what plan 03 thought, and a correction arrives as plan 04 rather than as an edit to plan 03.
- **Each `spec.md` is that plan's delta.** It carries all 19 sections, but §8 lists only the requirements this plan introduces. Reading `plan-03/spec.md` tells you everything plan 03 must do without opening plan 01. The union of every spec is the app.
- **Stage and task IDs restart inside each plan.** `plan-02/slice/01-p0/` is the first stage of plan 02, not the sixth stage of the app, and `TASK-001` exists once per plan folder. A plan reads top to bottom on its own.

`context.md` at the root is what spans them: its `Current Development Status` carries one line per plan with three parts — the plan's identity, its stage states, and a one-clause summary of what that plan's `spec.md` builds:

```markdown
- plan-01 — initial build — p0–p2 ✓ — expense entry, monthly total, correcting a past entry
- plan-02 — monthly budgets — p0 ✓ | p1 in progress — a budget per category, and spending shown against it
- plan-03 — CSV export — not sliced yet — expenses and a monthly summary exported as CSV
```

That summary clause is what makes the file answer "what does this project actually do?" on its own: a fresh agent reads `context.md` and knows the project's state and its capabilities without opening a single spec. `/plan` writes the clause; `/slice` and the four later skills touch only the state slot.

## The flow

```text
                    +------------------+
                    |       INIT       |
                    | AGENTS.md        |
                    | context.md       |
                    +---------+--------+
                              |
                              v
                    +------------------+
                    |       PLAN       |
                    | creates          |
                    | specs/NN-slug/   |
                    |   spec.md        |
                    +---------+--------+
                              |
        a later feature re-enters here and creates the NEXT
        plan folder — it never edits the one that exists
                              |
                              v
                    +------------------+
                    |      SLICE       |
                    | fills that plan's|
                    | slice/NN-pK/     |
                    +---------+--------+
                              |
                              v
                    +------------------+
                    |       EXEC       |
                    | Task -> Code     |
                    +---------+--------+
                              |
                 +------------+------------+
                 |                         |
                 v                         v
          +-------------+           +-------------+
          |   REVIEW    |           |    CHECK    |
          | Code -> MR  |           |   Tests     |
          +------+------+           +------+------+
                 |                         |
             findings                   failures
                 |                         |
                 +------------+------------+
                              |
                              v
                    +------------------+
                    |       FIX        |
                    +---------+--------+
                              |
                              v
                    +------------------+
                    | REVIEW           |
                    | and CHECK        |
                    | again            |
                    +------------------+
```

REVIEW and CHECK are parallel siblings, not a chain. The edges are `exec -> review` and `exec -> check`. There is no `exec -> review -> check` edge. Either can run first, either can run without the other having run, and both can run at the same time on the same task.

CHECK does not run after every single task by default. It runs when a stage is finished, or when a task needs a test result before anyone can trust it.

## Growing the project, one plan at a time

```text
/plan  "aplikasi catat pengeluaran"   → specs/01-initial-build/
/slice 01-initial-build                     spec.md + slice/01-p0..03-p2
  ... work p0 .. p2 ...

/plan  "tambah budget bulanan"        → specs/02-monthly-budgets/
/slice 02-monthly-budgets                   spec.md + slice/01-p0..03-p2
  ... work p0 .. p2 ...

/plan  "tambah ekspor CSV"            → specs/03-csv-export/
/slice 03-csv-export                        spec.md + slice/01-p0..02-p1
```

Each iteration is independent: a new folder, a new spec, a new stage sequence starting at `01-p0`, and a new `TASK-001`. `plan-01` is untouched throughout. `context.md` gains one ledger line per plan and keeps the older ones.

What the plan spec cannot say — because it only ever states its own delta — is why the plan exists: what the user actually asked for, what already existed and was reused, what was deliberately refused, and which decisions were taken with which alternatives dropped. That history lives across the plan folders themselves: `plan-02/spec.md`'s §2 and §18 record the gap plan 02 was answering, and `context.md`'s `Important Decisions` carries the current truth. Reading the plan folders in order is reading the app's history in order.

## Skill by skill

Plugin skills are namespaced by the plugin name; the bare names `/init`, `/plan`, and `/review` are claimed by Claude Code's own built-ins, so the namespaced form is required for those and is safe for all seven.

### INIT — `/developer-plenger:init`

- **Input:** the existing repository.
- **Output:** `AGENTS.md` and an empty `context.md` at the project root.
- **Does:** reads any existing `AGENTS.md`, compares it against the pack contract, and writes or repairs it. The content is the same in every project — the workflow chain (`INIT → PLAN → SLICE → EXEC → (REVIEW ∥ CHECK) → FIX`), the seven skill rules, the artifact table, and the task-state rule — and it describes the pack, never the project. Then it creates `context.md` with its thirteen sections empty, because nothing has been planned yet. It asks the user nothing, inspects no project facts, and creates no directory: `specs/` appears on the first `/plan`.
- **Exit condition:** `AGENTS.md` exists and matches the pack contract section for section, naming all seven skills; `context.md` exists with every section empty and `Current Phase: INIT`.
- **Hand-off:** `/developer-plenger:plan`.

### PLAN — `/developer-plenger:plan`

- **Input:** the user's idea in plain prose, plus `AGENTS.md`, `context.md`, and every existing plan's `spec.md` and the code.
- **Output:** `specs/NN-<plan-slug>/spec.md` — a **new** plan folder with its own specification — and the project's sections in `context.md`.
- **Does:** works out which plan this is (the next free number), reads what already exists and classifies each part of the request as already there, partly there, contradicted, or new ground; critiques it against target user, features, development, security, and scalability; identifies ambiguity; asks the unresolved questions; records the decisions; then writes the plan's spec and updates `context.md`. It detects the stack and the repository's own conventions and records them in `context.md`'s `Technology` and `Project Rules` — `AGENTS.md` carries only the pack contract, so this run owns the repository's facts. A later run creates a new folder rather than editing an existing spec: earlier plans are history.
- **Exit condition:** `specs/NN-<plan-slug>/spec.md` exists with every section filled or explicitly `None`, every functional requirement is numbered and testable, no unresolved question lives outside §17, and `context.md` carries this plan's ledger line reading `not sliced yet`.
- **Hand-off:** `/developer-plenger:slice NN-<plan-slug>`.

### SLICE — `/developer-plenger:slice`

- **Input:** `specs/NN-<plan-slug>/spec.md` and `context.md`.
- **Output:** that plan's `slice/NN-pK/tasks.md`, `K` starting at `0`.
- **Does:** picks the plan — the argument, or the newest plan with no slices yet, asking when more than one qualifies. Establishes which of the plan's requirements are still unsliced, cuts them into development stages (each delivering an end-to-end capability, not a layer), puts the tracer bullet first as `01-p0`, resolves dependencies including edges back to an earlier plan's stages, and writes each stage's `tasks.md`. Both stage and task numbering restart here: `01-p0` and `TASK-001` are this plan's.
- **Exit condition:** every unsliced §8 requirement of this plan maps to exactly one new stage, every task has verifiable acceptance criteria, every dependency resolves, and no other plan's slices were touched.
- **Hand-off:** `/developer-plenger:exec`, with this plan's ledger line in `context.md` updated to name the stages before reporting.

### EXEC — `/developer-plenger:exec NN-<plan-slug>/NN-pK`

- **Input:** `AGENTS.md`, `context.md`, that plan's `spec.md`, and the slice file.
- **Output:** application source code, plus the `Implemented` checkbox flipped on the tasks it completed.
- **Does:** resolves the plan first, because task IDs restart and a bare `TASK-001` exists in every sliced plan; then checks task dependencies, inspects the existing code, implements the task, and validates that it actually runs. Only then does it check the box. A task whose `#### Dependencies` list contains an unchecked task is not implemented.
- **Exit condition:** the code runs and the task's `Implemented` checkbox is `- [x]`. `Reviewed` and `Tested` are untouched.
- **Hand-off:** `/developer-plenger:review` and `/developer-plenger:check`, in either order or together.

### REVIEW — `/developer-plenger:review NN-<plan-slug>/NN-pK`

- **Input:** the task, the plan spec section it came from, its acceptance criteria, and the implementation.
- **Output:** that plan's `reviews/TASK-NNN.md`, plus the `Reviewed` checkbox flipped when the review passes.
- **Does:** checks logic, architecture, security, maintainability, edge cases, and requirement compliance. Each problem becomes a numbered finding inside the review document: `FINDING-001` in `specs/02-monthly-budgets/reviews/TASK-003.md`, referenced as `plan-02/TASK-003#FINDING-001` when the plan is not obvious. Because a plan spec states only its delta, a requirement the task implements may belong to an earlier plan — the review opens that plan's spec too rather than reporting against a document that never claimed the behaviour.
- **Exit condition:** the review document exists and `Reviewed` is flipped only when no Open finding of severity Medium or higher remains.
- **Hand-off:** `/developer-plenger:fix` when findings are Open; `/developer-plenger:check` runs independently, not after this.

### CHECK — `/developer-plenger:check NN-<plan-slug>/NN-pK`

- **Input:** the task's acceptance criteria and the implementation.
- **Output:** that plan's `checks/TASK-NNN.md`, plus the `Tested` checkbox flipped when every criterion passes.
- **Does:** detects the testing ecosystem in the repository instead of assuming one, determines what tests already exist, runs them, analyzes the result, and records one row of evidence per acceptance criterion with the exact command and exit code.
- **Exit condition:** every acceptance criterion has passing evidence, or the gaps and failures are written down and `Tested` stays unchecked.
- **Hand-off:** `/developer-plenger:fix` when failures or gaps exist; `/developer-plenger:review` runs independently, not after this.

### FIX — `/developer-plenger:fix`

- **Input:** that plan's `reviews/TASK-NNN.md` and/or `checks/TASK-NNN.md`.
- **Output:** repaired source code and that plan's `fixes/TASK-NNN.md`.
- **Does:** resolves the findings and failures, then resets exactly the checkboxes whose evidence its change invalidated. A code change always resets `Reviewed` and `Tested`. If the fix shows the task was never really implemented, it resets `Implemented` too. Reset means `- [ ]`.
- **Exit condition:** the recorded findings are addressed and the affected checkboxes are unchecked, not silently re-checked.
- **Hand-off:** `/developer-plenger:review` and `/developer-plenger:check` run again on the reset boxes.

## Task state

A task carries three independent checkboxes. They are the only state carrier; there is no `status:` field anywhere.

- `Implemented` is owned by `/developer-plenger:exec`, and is set only when the code actually runs.
- `Reviewed` is owned by `/developer-plenger:review`, and is set only when no unresolved finding of Medium severity or higher remains.
- `Tested` is owned by `/developer-plenger:check`, and is set only when every acceptance criterion has passing evidence.

`DONE` is derived when all three are checked, and is never stored. See [state-machine.md](state-machine.md) for the full model.

## The cursor in context.md

`Current Phase` is the one field outside `/developer-plenger:plan`'s sole ownership, because it is the workflow's cursor rather than project content. It holds exactly one word, one of the seven step names:

```text
INIT | PLAN | SLICE | EXEC | REVIEW | CHECK | FIX
```

The skill that just ran sets it to its own step name, with no `TASK-NNN` suffix, no plan name, no stage name and no free text. Naming the step just completed is the same statement as saying where the chain is. Which plan and stage were being worked on goes in the skill's report, not in this field.

Everything else in `context.md` belongs to `/developer-plenger:plan` — except `Current Development Status`, whose state slots are rewritten by whichever skill changed the boxes they count, one plan's line at a time. The summary clause on each line stays `/plan`'s: a later skill flips boxes, it does not restate what the plan delivers.

The skill that writes an artifact also creates its directory, so a fresh clone acquires `specs/01-<plan-slug>/` on the first `/developer-plenger:plan`, then that plan's `slice/`, `reviews/`, `checks/` and `fixes/` as each is first needed. See [architecture.md](architecture.md).

## Cold start

A user with an idea and an empty repository:

1. Type `/developer-plenger:init`. The agent writes `AGENTS.md`, the pack's registration file, and an empty `context.md`; it asks nothing.
2. Type `/developer-plenger:plan` and describe the idea in a sentence or two. The agent asks its clarifying questions, detects the stack and the repository's conventions, then creates `specs/01-<plan-slug>/spec.md` and adds the project's sections and this plan's ledger line to `context.md`.
3. Type `/developer-plenger:slice 01-<plan-slug>`. The agent cuts the spec into `specs/01-<plan-slug>/slice/01-p0/tasks.md` and the following stages, with tasks and acceptance criteria.
4. Type `/developer-plenger:exec 01-<plan-slug>/01-p0`. The agent implements the tasks in order, respecting dependencies, and flips each `Implemented` box as the code runs.
5. Type `/developer-plenger:review 01-<plan-slug>/01-p0` and `/developer-plenger:check 01-<plan-slug>/01-p0`. These are siblings: run both, in either order. Each writes its document under that plan's `reviews/` or `checks/`.
6. Type `/developer-plenger:fix` with the findings and failures in hand. The agent repairs the code, resets the invalidated checkboxes, and the review and check run again on those boxes.

When every task in a stage reaches `DONE`, the next stage is already waiting at the next number. When the app gains a feature, go back to step 2: `/developer-plenger:plan` creates `specs/02-<plan-slug>/` with its own spec, `/developer-plenger:slice 02-<plan-slug>` gives it its own `01-p0`, and `context.md` gains a second ledger line while the first stays exactly as it was.
