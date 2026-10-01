# Design gate — when /exec must stop for a missing design system

`/developer-plenger:exec` refuses to implement a **UI task** until the app has a
`design.md`. This reference is the gate's rule: how to classify a task, the two
conditions that block, the exact messages, and what to read on the way through.

It exists because UI written without a shared system drifts: each task picks its
own colors, spacing and states, and the app ends up with five button styles. The
gate makes the system a precondition, the same way a missing slice file is.

## When the gate runs

In `/exec`'s step 2, after the plan and task are known (so the task can be
classified) and before any file is inspected or written. It reads:

1. `design.md` at the repo root — whether it exists, and its `## Applicability`.
2. The task's own text and acceptance criteria, plus the plan `spec.md` sections
   it descends from, to classify the task.
3. `context.md` → `Technology`, for the app-level signal.

## Classifying the task

Use the same signals `/design` uses — the full matrix is in
`skills/design/references/design-format.md` → "Detecting UI vs not". Short form:

- **UI task** — its acceptance criteria or description name something a person
  **sees or clicks**: a screen, a rendered element, a style, a layout.
- **Non-UI task** — its criteria name data, an endpoint, a schema, an exit code,
  a build artifact, with no rendered outcome.

When the signals conflict or the app-level `Technology` is `unknown`, **do not
guess-block**. Name the ambiguity and ask the user once: "Is this task
user-facing UI?" Record the answer and continue. A false block on a backend task
is as costly as a missed one.

## The two block conditions

**1. `design.md` is missing — block, always.**

Whatever the task type, a missing `design.md` means the app has never been
through `/design`:

```
BLOCKED — no design system. /exec cannot implement UI until design.md exists at
the repo root. Run /developer-plenger:design, then re-run
/exec NN-<plan-slug>/NN-pK.
```

The block is uniform on purpose: `/design` writes either the UI system or the
`not applicable` stub, so the fix is the same command whether or not the app has
a UI, and `/exec` never has to decide app type at the gate.

**2. `design.md` is present but `## Applicability` is `not applicable`, and the
task is UI — block.**

The app was classified as having no UI, but this task is user-facing — a plan
added a UI to a backend, or the classification was wrong:

```
BLOCKED — design.md is marked "not applicable" but this task is UI. Re-run
/developer-plenger:design to produce the UI system, or reclassify the task.
```

## The pass condition

The gate opens when `design.md` exists **and** either:

- `## Applicability` is `UI` and the task is UI — read the relevant sections
  (`Colors / Tokens`, `Typography`, `Spacing & Radius`, `Components`, `States`,
  `Accessibility`) and implement against them; or
- the task is non-UI — proceed; the design system does not constrain it.

On a UI task, the components and states the task uses come from `design.md`, not
from the developer's taste. A task that needs a component the system does not
define is a signal to re-run `/design`, not to invent one inline; note it in the
report.
