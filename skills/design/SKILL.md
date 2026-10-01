---
name: design
description: >
  Fetch design guidance tuned to the app's stack and domain and write the
  app-wide design.md — colors, type, spacing, components, states, accessibility —
  or a not-applicable stub for a project with no UI. Use for /design, after a
  /plan run, or whenever a UI task needs a design system before /exec can build
  it. Never writes source code; a run that adds no new UI changes nothing.
---

# Design — the app-wide design system

`/design` turns a plan's requirements plus the app's stack into a single
`design.md` at the repo root: the colors, type, spacing, components, states and
accessibility rules every UI task obeys. It is the run between `/plan` and
`/slice` — the plan says what to build, the design says what it looks like, the
slices say in what order.

Unlike every other artifact the pack produces, `design.md` is **app-wide, not
per-plan**: it is a peer of `AGENTS.md` and `context.md`, and each plan's `/design`
run extends it rather than creating its own. `/design` writes no source code and
flips no checkbox.

Read `references/design-format.md` before step 2 for the section contract, the
update discipline and the UI-detection matrix, and `references/sourcing.md`
before step 5 for how to fetch and adapt sources.

## 1. Load the context, and pick the plan

Read, in this order:

1. `AGENTS.md` — the registered workflow, artifact paths and skill rules.
2. `context.md` — the project's memory, including the plan ledger and `Technology`.
3. The newest plan's `specs/NN-<plan-slug>/spec.md` — the requirements this
   design must serve — or the plan named in the invocation.
4. `design.md` at the repo root, if it exists.

If `AGENTS.md` is missing, stop and send the user to `/init`; if `context.md` is
missing, send them to `/plan`; if no plan spec exists, send them to `/plan`.
Never invent requirements to design against.

**Pick the plan before reading its spec.** `/design NN-<plan-slug>` names it
explicitly. Bare `/design` means the newest plan — the one `/plan` just wrote.
Say which plan you picked before continuing.

**Completion criterion:** you can name the plan this run serves and quote its
title, or you stopped and named the skill the user must run first.

## 2. Decide applicability

Read `references/design-format.md` → "Detecting UI vs not". Classify the project
from `context.md` → `Technology` and the plan `spec.md` → §10 User Flow and §5
Target Users. Say the verdict and the evidence that produced it.

When `Technology` is `unknown` or the signals conflict, do not guess: **ask the
user once** — "Does this app render a UI a user sees?" — and record the answer as
the evidence. A project with no UI (a CLI, a library, a service, a backend) is
`not applicable`, and this run writes the minimal stub (step 6) rather than a
system.

**Completion criterion:** you can state `Applicability: UI` or `not applicable`,
with the file and section that proves it, or the user's answer if it was
ambiguous.

## 3. Read what already exists

Read the existing `design.md`, if present, and the newest two or three plans'
`spec.md` — §7 User Stories, §10 User Flow, §8 Functional Requirements. For each
UI element the new plan needs, decide and say which:

- **Already designed** — the component or token is in the current system. Reuse
  it; the request adds nothing to `design.md`.
- **Extended** — a component the system has, used in a new variant or state.
  Name the section that grows.
- **New** — nothing covers it; the system gains a component or a token.
- **Contradicted** — the new plan wants something the current system forbids.
  That is a decision to surface, not a silent override.

**No-op path:** if the plan adds no UI the system does not already cover, this
run changes nothing — report that, set the cursor (step 7), and go to step 8.
Do not rewrite sections to look busy.

**Completion criterion:** every UI element the plan needs is classified, or you
have established there are none.

## 4. Propose candidate design systems

Read `references/sourcing.md`. Offer the user **2–3 candidates** matched to the
stack and domain, each with a one-line reason, and recommend one. Take the user's
choice; if they name their own, use it. Skip this step on the non-UI path and on
a pure no-op.

**Completion criterion:** one candidate is chosen and it is named, or the run is
the non-UI/no-op path and no choice was needed.

## 5. Fetch and adapt

Read `references/sourcing.md`. `WebSearch` for the chosen system's current
documentation and `WebFetch` its primary pages; fetch the token names and values,
the type and spacing scales, the component list, and the accessibility targets
you actually need. Adapt them to this app — pick the roles it has, cut the scales
to its components. Record every source's URL and what was adapted from it.

`WebFetch` cannot reach authenticated or private sources; when the user points at
one, say so and fall back to public sources or ask them to paste the tokens.
Never claim a source you did not open.

**Completion criterion:** every color, type step, spacing step and component has
a named source or an explicitly-marked derivation.

## 6. Write or update design.md

Read `references/design-format.md` for the contract. Write `design.md` at the
repo root:

- **First run** — the whole file, all 10 sections, each filled or explicitly
  `None`.
- **Later or no-op run** — rewrite only the sections step 3 marked as changed;
  merge new components into the existing `## Components`; never append a second
  block, a dated entry, or a history. A no-op writes nothing.

On the **non-UI path**, write the minimal stub: `## Applicability` reading
`not applicable` with its evidence, and every other section `None`. The file
still exists — that is what keeps `/exec`'s gate uniform.

**Completion criterion:** `design.md` exists at the repo root and matches
`references/design-format.md` section for section; or the no-op path left it
unchanged and you can say so.

## 7. Update context.md

Follow `skills/plan/references/context.md`. Set `## Design` to point at
`design.md` with its one-line status — `design.md — <UI system | not applicable>
— <what it covers>`. Set `Current Phase` to `DESIGN`. Change nothing else; the
eleven project sections belong to `/plan`, and `Current Development Status`'s
summary clauses are not yours to touch.

**Completion criterion:** `context.md` reads `Current Phase: DESIGN` and its
`## Design` section names `design.md` and its applicability; no other section
changed.

## 8. Report

Tell the user: the plan this run served; the applicability verdict and its
evidence; which sections were written, rewritten, or left unchanged; the sources
used; any component the plan needs that the system does not yet define; and the
next command — `/slice NN-<plan-slug>`.

**Completion criterion:** the user knows what `design.md` now says and what to
run next.
