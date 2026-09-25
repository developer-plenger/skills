# Workflow

The `developer-plenger` pack is one workflow, not seven independent prompts. Each skill consumes the artifact the previous one produced and leaves exactly one artifact behind. Nothing important lives in the chat log. The single exception to "one writer per artifact" is the `Current Phase` cursor described below, which every skill advances.

## The flow

```text
                    +-------------+
                    |    INIT     |
                    |  AGENTS.md  |
                    +------+------+
                           |
                           v
                    +-------------+
                    |    PLAN     |
                    | Idea -> Spec|
                    +------+------+
                           |
                           v
                    +-------------+
                    |    SLICE    |
                    | Spec -> Tasks|
                    +------+------+
                           |
                           v
                    +-------------+
                    |    EXEC     |
                    | Task -> Code|
                    +------+------+
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
                    +-------------+
                    |     FIX     |
                    +------+------+
                           |
                           v
                    +-------------+
                    | REVIEW      |
                    | and CHECK   |
                    | again       |
                    +-------------+
```

REVIEW and CHECK are parallel siblings, not a chain. The edges are `exec -> review` and `exec -> check`. There is no `exec -> review -> check` edge. Either can run first, either can run without the other having run, and both can run at the same time on the same task.

CHECK does not run after every single task by default. It runs when a slice or phase is finished, or when a task needs a test result before anyone can trust it.

## Phase by phase

Plugin skills are namespaced by the plugin name; the bare names `/init`, `/plan`, and `/review` are claimed by Claude Code's own built-ins, so the namespaced form is required for those and is safe for all seven.

### INIT — `/developer-plenger:init`

- **Input:** the existing repository.
- **Output:** `AGENTS.md` at the project root.
- **Does:** reads any existing `AGENTS.md`, compares it against the pack contract, and writes or repairs it. The content is the same in every project — the workflow chain (`INIT → PLAN → SLICE → EXEC → (REVIEW ∥ CHECK) → FIX`), the seven skill rules, the artifact table, and the task-state rule — and it describes the pack, never the project. It asks the user nothing and inspects no project facts.
- **Exit condition:** `AGENTS.md` exists, matches the pack contract section for section, and names all seven skills in its Skill Rules section.
- **Hand-off:** `/developer-plenger:plan` reads `AGENTS.md` for the pack contract, then takes the idea and the project's own facts.

### PLAN — `/developer-plenger:plan`

- **Input:** the user's idea in plain prose, plus `AGENTS.md`.
- **Output:** `docs/plan/SPEC.md` (19 fixed sections) and `docs/plan/CONTEXT.md` (13 fixed sections, under one page).
- **Does:** understands the idea, critiques it against target user, features, development, security, and scalability, identifies ambiguity, asks the unresolved questions, records the decisions, then writes both documents. It also detects the stack and the project's own conventions from the repository and records them in `CONTEXT.md` — `AGENTS.md` carries only the pack contract, so this run owns the project's facts. `SPEC.md` is what to build; `CONTEXT.md` is what the agent must keep in mind every session.
- **Exit condition:** every section of `SPEC.md` is answered or explicitly listed under Open Questions, every settled choice is recorded under Decisions, `CONTEXT.md` fits under one page, and its `Technology` and `Project Rules` sections are filled from the repository or the user's answers.
- **Hand-off:** `/developer-plenger:slice` reads `SPEC.md`.

### SLICE — `/developer-plenger:slice`

- **Input:** `docs/plan/SPEC.md`.
- **Output:** `docs/phases/phase-NN-<slug>.md`, numbered from `phase-01`.
- **Does:** identifies user journeys, cuts them into vertical slices (each slice delivers an end-to-end capability, not a layer), prioritizes the tracer bullet that proves the slice through the whole stack, resolves dependencies between phases, then writes the phases with their tasks. Task IDs are global and unique across phases: `TASK-001`, `TASK-002`, and so on, zero-padded to three digits.
- **Exit condition:** every functional requirement in the spec maps to at least one task, every task has verifiable acceptance criteria, and every dependency points at a task ID or a phase that exists.
- **Hand-off:** `/developer-plenger:exec` reads one phase file.

### EXEC — `/developer-plenger:exec phase-01` or `/developer-plenger:exec TASK-001`

- **Input:** `AGENTS.md`, `docs/plan/CONTEXT.md`, `docs/plan/SPEC.md`, and the phase file.
- **Output:** application source code, plus the `Implemented` checkbox flipped on the tasks it completed.
- **Does:** checks task dependencies, inspects the existing code, implements the task, and validates that it actually runs. Only then does it check the box. A task whose `#### Dependencies` list contains an unchecked task is not implemented.
- **Exit condition:** the code runs and the task's `Implemented` checkbox is `- [x]`. `Reviewed` and `Tested` are untouched.
- **Hand-off:** `/developer-plenger:review` and `/developer-plenger:check`, in either order or together.

### REVIEW — `/developer-plenger:review phase-01` or `/developer-plenger:review TASK-001`

- **Input:** the task, the spec section it came from, its acceptance criteria, and the implementation.
- **Output:** `docs/reviews/TASK-NNN.md`, plus the `Reviewed` checkbox flipped when the review passes.
- **Does:** checks logic, architecture, security, maintainability, edge cases, and requirement compliance. Each problem becomes a numbered finding inside the review document: `FINDING-001` in `docs/reviews/TASK-003.md`, referenced elsewhere as `TASK-003#FINDING-001`.
- **Exit condition:** the review document exists and `Reviewed` is flipped only when no Open finding of severity Medium or higher remains.
- **Hand-off:** `/developer-plenger:fix` when findings are Open; `/developer-plenger:check` runs independently, not after this.

### CHECK — `/developer-plenger:check phase-01` or `/developer-plenger:check TASK-001`

- **Input:** the task's acceptance criteria and the implementation.
- **Output:** `docs/checks/TASK-NNN.md`, plus the `Tested` checkbox flipped when every criterion passes.
- **Does:** detects the testing ecosystem in the repository instead of assuming one, determines what tests already exist, runs them, analyzes the result, and records one row of evidence per acceptance criterion with the exact command and exit code.
- **Exit condition:** every acceptance criterion has passing evidence, or the gaps and failures are written down and `Tested` stays unchecked.
- **Hand-off:** `/developer-plenger:fix` when failures or gaps exist; `/developer-plenger:review` runs independently, not after this.

### FIX — `/developer-plenger:fix`

- **Input:** `docs/reviews/TASK-NNN.md` and/or `docs/checks/TASK-NNN.md`.
- **Output:** repaired source code and `docs/fixes/TASK-NNN.md`.
- **Does:** resolves the findings and failures, then resets exactly the checkboxes whose evidence its change invalidated. A code change always resets `Reviewed` and `Tested`. If the fix shows the task was never really implemented, it resets `Implemented` too. Reset means `- [ ]`.
- **Exit condition:** the recorded findings are addressed and the affected checkboxes are unchecked, not silently re-checked.
- **Hand-off:** `/developer-plenger:review` and `/developer-plenger:check` run again on the reset boxes.

## Task state

A task carries three independent checkboxes. They are the only state carrier; there is no `status:` field anywhere.

- `Implemented` is owned by `/developer-plenger:exec`, and is set only when the code actually runs.
- `Reviewed` is owned by `/developer-plenger:review`, and is set only when no unresolved finding of Medium severity or higher remains.
- `Tested` is owned by `/developer-plenger:check`, and is set only when every acceptance criterion has passing evidence.

`DONE` is derived when all three are checked, and is never stored. See [state-machine.md](state-machine.md) for the full model.

## Current Phase cursor

`docs/plan/CONTEXT.md` has one field outside `/developer-plenger:plan`'s sole ownership: `Current Phase`. Every skill writes it, because it is the workflow's shared cursor rather than project content. It holds exactly one word, one of the seven step names:

```text
INIT | PLAN | SLICE | EXEC | REVIEW | CHECK | FIX
```

The skill that just ran sets it to its own step name, with no `TASK-NNN` suffix: `/developer-plenger:plan` leaves `PLAN`, `/developer-plenger:exec` sets `EXEC`, `/developer-plenger:review` sets `REVIEW`, `/developer-plenger:check` sets `CHECK`, `/developer-plenger:fix` sets `FIX`. Naming the step just completed is the same statement as saying where the chain is, so no value carries a task ID or a destination. Everything else in `CONTEXT.md` belongs to `/developer-plenger:plan` alone.

The skill that writes an artifact also creates its directory, so a fresh clone acquires `docs/plan/` on the first `/developer-plenger:plan`, then `docs/phases/`, `docs/reviews/`, `docs/checks/`, and `docs/fixes/` as each is first needed. See [architecture.md](architecture.md).

## Cold start

A user with an idea and an empty repository:

1. Type `/developer-plenger:init`. The agent writes `AGENTS.md`, the pack's registration file; it asks nothing.
2. Type `/developer-plenger:plan` and describe the idea in a sentence or two. The agent asks its clarifying questions, detects the stack and the project's conventions, then writes `docs/plan/SPEC.md` and `docs/plan/CONTEXT.md`.
3. Type `/developer-plenger:slice`. The agent cuts the spec into `docs/phases/phase-01-<slug>.md` and following phases, with tasks and acceptance criteria.
4. Type `/developer-plenger:exec phase-01`. The agent implements the tasks in order, respecting dependencies, and flips each `Implemented` box as the code runs.
5. Type `/developer-plenger:review phase-01` and `/developer-plenger:check phase-01`. These are siblings: run both, in either order. Each writes its document under `docs/reviews/` or `docs/checks/`.
6. Type `/developer-plenger:fix` with the findings and failures in hand. The agent repairs the code, resets the invalidated checkboxes, and the review and check run again on those boxes.

When every task in a phase reaches `DONE`, `/developer-plenger:slice` produces the next phase from the remaining spec sections, and the loop repeats.
