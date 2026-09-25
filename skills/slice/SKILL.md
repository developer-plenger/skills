---
name: slice
description: >
  Slice a stable SPEC.md into ordered vertical slices, phase files, and TASK-NNN
  tasks with acceptance criteria. Use when the user runs /slice, asks to slice
  the spec, break a project into phases or vertical slices, order phases, plan a
  tracer bullet, or generate docs/phases/phase-NN-<slug>.md. Refuses while
  blocking open questions remain, and reports dependency cycles instead of
  emitting a broken plan.
---

# /slice

Cut a stable `docs/plan/SPEC.md` into ordered vertical slices and write them as phase
files under `docs/phases/`. Phase files are the contract `/exec` reads; this skill
writes planning artifacts only, never source code.

## 1. Load the context

Read, in this order:

1. `AGENTS.md` — project rules and the registered workflow.
2. `docs/plan/CONTEXT.md` — the one-page project summary.
3. `docs/plan/SPEC.md` — the thing you are slicing.

If `AGENTS.md` is missing, stop and send the user to `/init`; if either `docs/plan/`
file is missing, stop and send them to `/plan`. Never invent spec content to keep
moving — a slice built on guessed requirements is worse than no slice.

**Done when:** all three are read and you can name SPEC §7 (User Stories), §8
(Functional Requirements), §17 (Open Questions) and §19 (Acceptance Criteria).

## 2. Gate on open questions

Read SPEC §17. Classify each question as *blocking* (its answer changes which
slices exist) or *deferrable* (its answer changes only how a slice is
implemented). Report the list with your classification and let the user decide;
do not answer spec questions on their behalf.

**Done when:** no blocking question is unanswered. Carry deferrable questions
verbatim into the `## Objective` of the phase they affect so `/exec` sees the
unknown, and mention them in your report.

## 3. Identify the user journeys

From §7 and §10 (User Flow), list the end-to-end journeys a user will actually
walk. A journey is what someone does to get a result, not a screen or an
endpoint.

**Done when:** every user story in §7 belongs to at least one journey.

## 4. Cut vertical slices

Read `references/vertical-slice.md`. Map each journey to one or more slices, each
a thin path through every layer of the product that the user can exercise end to
end. Assign every functional requirement in §8 to exactly one slice; a
requirement that spans slices is how a slice ends up unverifiable.

**Done when:** each slice names the requirements it satisfies, and every §8
requirement appears in exactly one slice.

## 5. Put the tracer bullet first

Read `references/tracer-bullet.md`. Choose the slice that proves the end-to-end
path with the least functionality and make it phase 01 — it surfaces integration
risk while it is still cheap to act on.

**Done when:** phase 01 is a tracer bullet, or you have recorded which hard
dependency forced another phase first.

## 6. Resolve dependencies and order the phases

Read `references/dependency.md`. Draw the phase-level edges, order phases
topologically, and keep risk and unknowns early. If you find a cycle, stop and
report the concrete edges — never emit a plan you know is unorderable.

**Done when:** every phase has a non-empty `### BLOCKED BY` and `### BLOCKS`
(`- None` when there is nothing), the graph has no cycles, and each phase is
reachable from a root.

## 7. Write the phase files

Read `references/task-state.md` for the exact file shape, filename rules and
numbering. Files are `docs/phases/phase-NN-<slug>.md`, `NN` starting at `01`, the
slug lowercased-hyphenated from the objective (`phase-03-login-endpoint.md`).
Adding a phase appends the next number; never renumber existing ones — reviews
and checks refer to them by name.

**Done when:** each file has a non-empty Objective, Vertical Slice, Tracer
Bullet, BLOCKED BY and BLOCKS, plus at least one task.

## 8. Write the tasks

Same reference. Every task is born with all three boxes unchecked. `TASK-NNN` is
global and continues from the highest ID already under `docs/phases/` — never
reuse or skip one. Acceptance criteria come from the SPEC requirement the task
implements, and each one has to be observable from outside the code.

**Done when:** each task has one coherent change, its own observable criteria,
and a `#### Dependencies` list (`- None` when it has none).

## 9. Self-check the plan

Before reporting, walk the phases once and confirm:

- every §8 requirement lands in exactly one slice;
- no slice is a single layer (a models-only or UI-only phase);
- the dependency graph is acyclic and no phase blocks itself;
- task IDs are unique, gapless and zero-padded;
- every task's criteria could fail on a stub — those are the criteria worth keeping.

**Done when:** all five hold, or you have fixed the phase files.

## 10. Update `docs/plan/CONTEXT.md`

Set `Current Phase` to `SLICE`, and rewrite `Current Development Status` as the
short phase list with each phase's state — max ~6 lines; condense older phases
into a range when the list grows past that.

**Done when:** both fields describe the plan you just wrote.

## 11. Report

Tell the user: phase files created or amended, the requirement coverage summary,
any blocking open question, and the next command (`/exec phase-01` or
`/exec TASK-001`).

**Done when:** the user knows the plan exists and what to run next.
