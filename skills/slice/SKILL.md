---
name: slice
description: >
  Slice a plan's specification into ordered development stages and TASK-NNN
  tasks with acceptance criteria, written to specs/NN-<plan-slug>/slice/NN-pK/tasks.md.
  Use when the user runs /slice, asks to slice a plan, break a spec into phases
  or slices, order the development stages, plan a tracer bullet, or generate a
  slice's tasks.md. Refuses while blocking open questions remain, and reports
  dependency cycles instead of emitting a broken plan.
---

# /slice

Cut one plan's `spec.md` into ordered development stages and write them as `specs/NN-<plan-slug>/slice/NN-pK/tasks.md`. A slice is a development stage of the plan that produced it: the plan says what to build, the slices say in what order and in how many steps. Slice files are the contract `/exec` reads; this skill writes planning artifacts only, never source code.

## 1. Load the context, and pick the plan

Read, in this order:

1. `AGENTS.md` — the registered workflow, artifact paths and skill rules.
2. `context.md` — the project's memory: what it is, and which plans exist.
3. The target plan's `specs/NN-<plan-slug>/spec.md` — the thing you are slicing.

**Pick the plan before reading its spec.** `/slice NN-<plan-slug>` names it explicitly. Bare `/slice` means: use the newest plan that has no slices yet. When more than one such plan exists, ask — list each with its title and how many requirements it carries — because slicing the wrong plan produces a stage plan for work nobody asked to sequence yet.

If `AGENTS.md` is missing, stop and send the user to `/init`; if `context.md` is missing, stop and send them to `/plan`. Never invent spec content to keep moving — a slice built on guessed requirements is worse than no slice. A plan whose `spec.md` does not exist is not sliceable: send the user back to `/plan`.

**Done when:** you can name the plan you are slicing, and you can name its §7 (User Stories), §8 (Functional Requirements), §17 (Open Questions) and §19 (Acceptance Criteria).

## 2. Establish what still needs slicing

List the slice folders already under `specs/NN-<plan-slug>/slice/`.

- **No slice folders** — a fresh plan; every §8 requirement is unsliced.
- **Slice folders exist** — this run appends the stages the plan still needs. Everything already written is left exactly as it is: no rewording, no renumbering, no merging.

A slice folder belongs to exactly one plan, so its numbering restarts with each plan: `plan-02/slice/01-p0/` is the first stage of plan 02, unrelated to `plan-01/slice/01-p0/`.

**Done when:** you can list the requirement IDs that still need a stage, and you know the next free slice number in this plan.

## 3. Gate on open questions

Read the plan spec's §17. Classify each question as *blocking* (its answer changes which stages exist) or *deferrable* (its answer changes only how a stage is implemented). Report the list with your classification and let the user decide; do not answer spec questions on their behalf.

A question no unsliced requirement depends on does not block this run, even if it is still open — say so rather than refusing to slice.

**Done when:** no blocking question is unanswered. Carry deferrable questions verbatim into the `## Objective` of the stage they affect so `/exec` sees the unknown, and mention them in your report.

## 4. Identify the user journeys

From the plan spec's §7 and §10 (User Flow), list the end-to-end journeys this plan makes possible. A journey is what someone does to get a result, not a screen or an endpoint.

When §10 says the flow is unchanged from an earlier plan, use that plan's journey and say so — the stages still have to be cut against a real journey, and naming which plan supplied it is what keeps the cut honest.

**Done when:** every user story in this plan's §7 belongs to at least one journey.

## 5. Cut vertical stages

Read `references/vertical-slice.md`. Map each journey to one or more stages, each a thin path through every layer of the product that the user can exercise end to end. Assign every unsliced requirement in §8 to exactly one stage; a requirement that spans stages is how a stage ends up unverifiable.

**Done when:** each new stage names the requirements it satisfies, and every unsliced §8 requirement appears in exactly one of them.

## 6. Put the tracer bullet first

Read `references/tracer-bullet.md`. On a plan's first slice run, choose the stage that proves the end-to-end path with the least functionality and make it `01-p0` — it surfaces integration risk while it is still cheap to act on. Note that on a later plan the app already exists, so the tracer bullet is the thinnest path *this plan's* feature travels, not a new whole-product spike.

**Done when:** this plan's first stage is a tracer bullet, or you have recorded which hard dependency forced another stage first.

## 7. Resolve dependencies and order the stages

Read `references/dependency.md`. Draw the stage-level edges, including edges from this plan's stages back to work an earlier plan delivered, order them topologically, and keep risk and unknowns early. If you find a cycle, stop and report the concrete edges — never emit a plan you know is unorderable.

**Done when:** every new stage has a non-empty `### BLOCKED BY` and `### BLOCKS` (`- None` when there is nothing), the graph has no cycles, and each stage is reachable from a root.

## 8. Write the slice files

Read `references/task-state.md` for the exact file shape, folder naming and numbering. Folders are `specs/NN-<plan-slug>/slice/NN-pK/` holding `tasks.md`, `K` starting at `0` — `specs/02-monthly-budgets/slice/01-p0/tasks.md`.

Append only within the plan: a plan whose stages end at `03-p2` gets `04-p3` next. Never renumber or rewrite an existing stage folder, and never touch another plan's slices — reviews, checks and fix records refer to them by path, and a task that has been started keeps its ID, its boxes and its wording.

**Done when:** each new `tasks.md` has a non-empty Objective, Vertical Slice, Tracer Bullet, BLOCKED BY and BLOCKS, plus at least one task.

## 9. Write the tasks

Same reference. Every task is born with all three boxes unchecked. `TASK-NNN` starts at `TASK-001` **within this plan** and continues from the highest ID already found in this plan's slice folders — a plan folder is the namespace, so two plans may each hold a `TASK-001`. Acceptance criteria come from the plan spec's requirement the task implements, and each one has to be observable from outside the code.

**Done when:** each task has one coherent change, its own observable criteria, and a `#### Dependencies` list (`- None` when it has none).

## 10. Self-check the stage plan

Before reporting, walk the new stages once and confirm:

- every unsliced §8 requirement lands in exactly one new stage;
- no stage is a single layer (a models-only or UI-only stage);
- the dependency graph is acyclic and no stage blocks itself;
- task IDs are unique, gapless and zero-padded *within this plan*;
- every task's criteria could fail on a stub — those are the criteria worth keeping.

**Done when:** all five hold, or you have fixed the slice files.

## 11. Update `context.md`

Following `skills/plan/references/context.md`: set `Current Phase` to `SLICE`, and replace this plan's `not sliced yet` with the stages it just produced — `plan-02 — monthly budgets — p0 pending | p1 pending — a budget per category, and spending shown against it`. Update the trailing task count.

Touch the state slot and the count only. The summary clause is `/plan`'s, and rewriting it is how four skills end up disagreeing about what the plan delivers. Change nothing else in the file, and never touch another plan's line: a skill working in `plan-02` leaves `plan-01`'s exactly as it found it.

**Done when:** `Current Phase` names the step that ran, and this plan's line lists the stages you wrote.

## 12. Report

Tell the user: the plan sliced, the stage folders created, the requirement coverage summary, any blocking open question, and the next command — `/exec NN-<plan-slug>/NN-pK`, the plan-qualified form, because stage and task IDs restart per plan and a bare `01-p0` would be ambiguous the moment a second plan is sliced.

**Done when:** the user knows the stages exist and what to run next.
