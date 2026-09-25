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

### INIT — `/init`

- **Input:** the existing repository.
- **Output:** `AGENTS.md` at the project root.
- **Does:** detects the project type, reads what already exists, and writes the operating context: what the project is, the stack, the workflow chain (`INIT → PLAN → SLICE → EXEC → (REVIEW ∥ CHECK) → FIX`), the rules each skill must follow, the project's own conventions, and the artifact table.
- **Exit condition:** `AGENTS.md` exists, its placeholders are filled with observed facts rather than guesses, and it names all seven skills in its Skill Rules section.
- **Hand-off:** `/plan` reads `AGENTS.md` first, then asks the user for the idea.

### PLAN — `/plan`

- **Input:** the user's idea in plain prose, plus `AGENTS.md`.
- **Output:** `docs/plan/SPEC.md` (19 fixed sections) and `docs/plan/CONTEXT.md` (12 fixed sections, under one page).
- **Does:** understands the idea, critiques it against target user, features, development, security, and scalability, identifies ambiguity, asks the unresolved questions, records the decisions, then writes both documents. `SPEC.md` is what to build; `CONTEXT.md` is what the agent must keep in mind every session.
- **Exit condition:** every section of `SPEC.md` is answered or explicitly listed under Open Questions, every settled choice is recorded under Decisions, and `CONTEXT.md` fits under one page.
- **Hand-off:** `/slice` reads `SPEC.md`.

### SLICE — `/slice`

- **Input:** `docs/plan/SPEC.md`.
- **Output:** `docs/phases/phase-NN-<slug>.md`, numbered from `phase-01`.
- **Does:** identifies user journeys, cuts them into vertical slices (each slice delivers an end-to-end capability, not a layer), prioritizes the tracer bullet that proves the slice through the whole stack, resolves dependencies between phases, then writes the phases with their tasks. Task IDs are global and unique across phases: `TASK-001`, `TASK-002`, and so on, zero-padded to three digits.
- **Exit condition:** every functional requirement in the spec maps to at least one task, every task has verifiable acceptance criteria, and every dependency points at a task ID or a phase that exists.
- **Hand-off:** `/exec` reads one phase file.

### EXEC — `/exec phase-01` or `/exec TASK-001`

- **Input:** `AGENTS.md`, `docs/plan/CONTEXT.md`, `docs/plan/SPEC.md`, and the phase file.
- **Output:** application source code, plus the `Implemented` checkbox flipped on the tasks it completed.
- **Does:** checks task dependencies, inspects the existing code, implements the task, and validates that it actually runs. Only then does it check the box. A task whose `#### Dependencies` list contains an unchecked task is not implemented.
- **Exit condition:** the code runs and the task's `Implemented` checkbox is `- [x]`. `Reviewed` and `Tested` are untouched.
- **Hand-off:** `/review` and `/check`, in either order or together.

### REVIEW — `/review phase-01` or `/review TASK-001`

- **Input:** the task, the spec section it came from, its acceptance criteria, and the implementation.
- **Output:** `docs/reviews/TASK-NNN.md`, plus the `Reviewed` checkbox flipped when the review passes.
- **Does:** checks logic, architecture, security, maintainability, edge cases, and requirement compliance. Each problem becomes a numbered finding inside the review document: `FINDING-001` in `docs/reviews/TASK-003.md`, referenced elsewhere as `TASK-003#FINDING-001`.
- **Exit condition:** the review document exists and `Reviewed` is flipped only when no Open finding of severity Medium or higher remains.
- **Hand-off:** `/fix` when findings are Open; `/check` runs independently, not after this.

### CHECK — `/check phase-01` or `/check TASK-001`

- **Input:** the task's acceptance criteria and the implementation.
- **Output:** `docs/checks/TASK-NNN.md`, plus the `Tested` checkbox flipped when every criterion passes.
- **Does:** detects the testing ecosystem in the repository instead of assuming one, determines what tests already exist, runs them, analyzes the result, and records one row of evidence per acceptance criterion with the exact command and exit code.
- **Exit condition:** every acceptance criterion has passing evidence, or the gaps and failures are written down and `Tested` stays unchecked.
- **Hand-off:** `/fix` when failures or gaps exist; `/review` runs independently, not after this.

### FIX — `/fix`

- **Input:** `docs/reviews/TASK-NNN.md` and/or `docs/checks/TASK-NNN.md`.
- **Output:** repaired source code and `docs/fixes/TASK-NNN.md`.
- **Does:** resolves the findings and failures, then resets exactly the checkboxes whose evidence its change invalidated. A code change always resets `Reviewed` and `Tested`. If the fix shows the task was never really implemented, it resets `Implemented` too. Reset means `- [ ]`.
- **Exit condition:** the recorded findings are addressed and the affected checkboxes are unchecked, not silently re-checked.
- **Hand-off:** `/review` and `/check` run again on the reset boxes.

## Task state

A task carries three independent checkboxes. They are the only state carrier; there is no `status:` field anywhere.

- `Implemented` is owned by `/exec`, and is set only when the code actually runs.
- `Reviewed` is owned by `/review`, and is set only when no unresolved finding of Medium severity or higher remains.
- `Tested` is owned by `/check`, and is set only when every acceptance criterion has passing evidence.

`DONE` is derived when all three are checked, and is never stored. See [state-machine.md](state-machine.md) for the full model.

## Current Phase cursor

`docs/plan/CONTEXT.md` has one field outside `/plan`'s sole ownership: `Current Phase`. Every skill writes it, because it is the workflow's shared cursor rather than project content. It holds exactly one word, one of the seven step names:

```text
INIT | PLAN | SLICE | EXEC | REVIEW | CHECK | FIX
```

The skill that just ran sets it to its own step name, with no `TASK-NNN` suffix: `/plan` leaves `PLAN`, `/exec` sets `EXEC`, `/review` sets `REVIEW`, `/check` sets `CHECK`, `/fix` sets `FIX`. Naming the step just completed is the same statement as saying where the chain is, so no value carries a task ID or a destination. Everything else in `CONTEXT.md` belongs to `/plan` alone.

The skill that writes an artifact also creates its directory, so a fresh clone acquires `docs/plan/` on the first `/plan`, then `docs/phases/`, `docs/reviews/`, `docs/checks/`, and `docs/fixes/` as each is first needed. See [architecture.md](architecture.md).

## Cold start

A user with an idea and an empty repository:

1. Type `/init`. The agent inspects the repository and writes `AGENTS.md`.
2. Type `/plan` and describe the idea in a sentence or two. The agent asks its clarifying questions, then writes `docs/plan/SPEC.md` and `docs/plan/CONTEXT.md`.
3. Type `/slice`. The agent cuts the spec into `docs/phases/phase-01-<slug>.md` and following phases, with tasks and acceptance criteria.
4. Type `/exec phase-01`. The agent implements the tasks in order, respecting dependencies, and flips each `Implemented` box as the code runs.
5. Type `/review phase-01` and `/check phase-01`. These are siblings: run both, in either order. Each writes its document under `docs/reviews/` or `docs/checks/`.
6. Type `/fix` with the findings and failures in hand. The agent repairs the code, resets the invalidated checkboxes, and the review and check run again on those boxes.

When every task in a phase reaches `DONE`, `/slice` produces the next phase from the remaining spec sections, and the loop repeats.
