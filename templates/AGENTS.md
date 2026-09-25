# Project Context

## Project

{{Project name, a one-line description, and a summary of the repository layout: three to six top-level directories and what lives in each.}}

## Purpose

{{Why this project exists, in the user's terms. The problem it removes and the outcome a successful user gets — not a feature list.}}

## Target Users

- {{Who uses it, one line each. Internal and admin roles count.}}
- {{Secondary user, if any. Delete this bullet when there is none.}}

## Features

- {{Capability A — what the product does, not how it is built.}}
- {{Capability B}}
- {{Capability C}}

## Architecture

{{The shape: monolith or services, the boundaries, the data stores, the external services. Two to six lines. Include a diagram only if one already exists in the repository.}}

## Technology

- Language: {{language and version}} — {{source file that proves it}}
- Framework: {{framework and version}} — {{source file that proves it}}
- Package manager: {{package manager}} — {{lockfile that proves it}}
- Test runner: {{test runner detected in this repo, or "not detected"}} — {{config or manifest that proves it}}
- Build tooling: {{build tooling}} — {{source file that proves it}}
- Database: {{database, or "none"}} — {{source file that proves it}}
- Deployment: {{deployment target, or "unknown"}} — {{source file that proves it}}

## Workflow

This project uses the `developer-plenger` skill pack. The registered chain is:

```text
INIT → PLAN → SLICE → EXEC → (REVIEW ∥ CHECK) → FIX
```

REVIEW and CHECK are siblings of EXEC, never a chain: the edges are `exec → review` and `exec → check`, never `exec → review → check`. CHECK runs per finished slice or phase by default, plus whenever a single task needs a test result to be trusted. FIX resets the boxes its change invalidated.

Invoke with `/init`, `/plan`, `/slice`, `/exec TASK-NNN`, `/review TASK-NNN`, `/check TASK-NNN`, `/fix TASK-NNN`.

## Skill Rules

One entry per skill. All seven, in this shape.

### INIT

Detect the project from evidence and write this file. Never invent a fact it did not observe.

- Invocation: `/init`
- Input: the existing repository, plus any `AGENTS.md` or `CLAUDE.md` already there
- Produces: `AGENTS.md`

### PLAN

Turn a raw idea into a specification.

- Invocation: `/plan <idea>`
- Input: the user's idea, or an existing codebase plus the idea that lands on it
- Produces: `docs/plan/SPEC.md`, `docs/plan/CONTEXT.md`

### SLICE

Cut a stable specification into ordered vertical slices and tasks.

- Invocation: `/slice`
- Input: `docs/plan/SPEC.md`
- Produces: `docs/phases/phase-NN-<slug>.md`, and the global task ID sequence

### EXEC

Implement a task, and check its `Implemented` box only once the code actually runs. Never check a box the code does not earn.

- Invocation: `/exec TASK-NNN` or `/exec phase-NN`
- Input: the phase file, `docs/plan/SPEC.md`, `docs/plan/CONTEXT.md`, and the existing source
- Produces: source code; checks `Implemented`

### REVIEW

Review an implementation against its spec and acceptance criteria, recording one numbered finding per problem. Never edits the code it reviews.

- Invocation: `/review TASK-NNN` or `/review phase-NN`
- Input: the task, the spec section it came from, its acceptance criteria, and the implementation
- Produces: `docs/reviews/TASK-NNN.md`; checks `Reviewed` when no unresolved finding of Medium or higher remains

### CHECK

Detect the testing ecosystem instead of assuming one, then prove each acceptance criterion. Never checks `Tested` without passing evidence.

- Invocation: `/check TASK-NNN` or `/check phase-NN`
- Input: the task's acceptance criteria and the implementation
- Produces: `docs/checks/TASK-NNN.md`; checks `Tested` when every acceptance criterion has passing evidence

### FIX

Repair what review and check surfaced, then reset the boxes that evidence no longer covers. Never checks a box; reset always means `- [ ]`.

- Invocation: `/fix TASK-NNN#FINDING-NNN` or `/fix TASK-NNN`
- Input: `docs/reviews/TASK-NNN.md` and/or `docs/checks/TASK-NNN.md`
- Produces: fixes plus `docs/fixes/TASK-NNN.md`; resets the boxes its change invalidated

## Project Rules

{{This project's own conventions: branching, commit style, formatting, the commands to run before finishing, anything the user told you that is not already covered above. Keep to facts you were given.}}

- {{Rule 1}}
- {{Rule 2}}
- {{Rule 3}}

## Artifacts

| Artifact | Written by | Location |
|---|---|---|
| Operating context | `/init` | `AGENTS.md` |
| Specification | `/plan` | `docs/plan/SPEC.md` |
| Project context | `/plan` | `docs/plan/CONTEXT.md` |
| Phase plan | `/slice` | `docs/phases/phase-NN-<slug>.md` |
| Review | `/review` | `docs/reviews/TASK-NNN.md` |
| Check | `/check` | `docs/checks/TASK-NNN.md` |
| Fix | `/fix` | `docs/fixes/TASK-NNN.md` |

## Task State

Task state lives in the three checkboxes on the task: `Implemented`, `Reviewed`, `Tested`. There is never a `status:` field. One owner per box:

- `Implemented` is set by `/exec`.
- `Reviewed` is set by `/review`, only when no unresolved finding of severity Medium or higher remains.
- `Tested` is set by `/check`, only when every acceptance criterion has passing evidence.

`DONE` is derived: all three boxes checked. It is never stored. `/fix` resets the boxes its change invalidated; a code change always resets `Reviewed` and `Tested`.
