# Design — the design.md contract

`design.md` at the repo root is the application's design system: one file the
whole app obeys, so every `/exec` task that writes UI draws from the same
colors, type, spacing, components and states instead of inventing its own. It is
the **third root artifact**, beside `AGENTS.md` (how the pack works) and
`context.md` (what the project is), and it is the only produced artifact that is
**not** per-plan: it is app-wide and outlives every plan that contributed to it.

`/developer-plenger:design` owns it. Every `/exec` run that touches UI reads it
before writing; a UI task whose `design.md` is missing or marked not-applicable
is blocked. See `skills/exec/references/design-gate.md` for the gate.

## The 10 sections, in order

The order is fixed — later sections reference earlier ones, and the gate reads
`Applicability` first.

```markdown
# Design System

## Applicability
## Sources
## Colors / Tokens
## Typography
## Spacing & Radius
## Components
## States
## Accessibility
## Motion
## Do / Don't
```

Write every section. A section with nothing to say gets `None` — not an empty
heading and not an invented value. `None` is a real answer here: it says the
system considered the section and the app does not use it.

| Section | Contents | Budget |
|---|---|---|
| Applicability | Whether the app has a UI, the target platforms, and the stack the system targets. The one section the gate reads. | 1–3 lines |
| Sources | The design systems and references fetched, each with its URL, and what was adapted from it. | 3–8 bullets |
| Colors / Tokens | The palette as **named semantic tokens** (background, surface, text, primary, danger…), each with its value, plus the light/dark mapping and the contrast ratio of text on its background. | token list |
| Typography | Families, the type scale (sizes and line-heights), weights, and where each is used. | a few lines |
| Spacing & Radius | The spacing scale, the radius scale, and any grid or breakpoint rules. | a few lines |
| Components | The components this app uses, each with its variants and the states it supports. | one line per component |
| States | The cross-cutting states every interactive element must define: hover, focus, active, disabled, loading, empty, error. | a few lines |
| Accessibility | Contrast targets met, focus-ring rule, keyboard reachability, minimum target size, reduced-motion handling, and semantics. | a few bullets |
| Motion | Durations and easings, and which transitions use them. `None` if the app does not animate. | a few lines |
| Do / Don't | Anti-patterns specific to this app — the things a competent developer would otherwise do that this system forbids. | a few bullets |

## Applicability — the gate's input

`## Applicability` opens with exactly one of two verdicts:

- **`UI`** — the app renders an interface a person sees and interacts with. The
  remaining nine sections must be filled. This is the state that unblocks
  `/exec`'s UI tasks.
- **`not applicable`** — the app is a CLI, a library, a service or a backend with
  no rendered interface. The verdict line names the **evidence** that classified
  it (the `context.md` `Technology` value and the spec section that proves it),
  and the remaining nine sections are `None`.

A `design.md` marked `not applicable` is still a complete, valid artifact — it is
what makes the gate uniform, because the gate never has to reason about app type
itself. If a later plan adds a UI to an app that was not-applicable, `/design`
re-runs, rewrites `Applicability` to `UI`, and fills the sections.

## Update discipline

`design.md` is a snapshot of what is currently true, exactly like `context.md`.
Matching the rules in `skills/plan/references/context.md`:

- **Rewrite the affected section, never append.** A later `/design` run that adds
  a component or a breakpoint edits the section it belongs to. It does not add a
  second `## Components` block, a dated entry, or a "previously we used X" note.
- **Never let it become a changelog.** No dates, no history, no per-plan notes.
  The file states the current system; the plan specs carry why it changed.
- **The first run writes the whole file.** Later runs reconcile: diff the new
  plan's needs against the current system and rewrite only the sections that
  actually change. A run that finds nothing new writes nothing and says so.
- **One system, not one per plan.** Two plans that both add buttons extend the
  same `## Components` list; they do not create competing ones. If a new plan's
  need contradicts the current system, that is a decision to record and a section
  to rewrite, not a parallel definition.

## Detecting UI vs not

Both `/design` and `/exec` classify an app, or a task, as UI or not. There is no
single flag, so read the strongest available signal and say which it was:

| Signal | Reads as UI | Reads as not applicable |
|---|---|---|
| `context.md` → `Technology` | a frontend framework or UI toolkit (React, Vue, Svelte, Next, Flutter, SwiftUI, Jetpack Compose, a template engine, an HTML/CSS build) | a language/runtime with no rendering layer (a CLI framework, a library package, a server framework, a database, a build tool) |
| The plan `spec.md` → §10 User Flow, §5 Target Users | steps describing what a person *sees* and *clicks* | steps describing commands, requests, or API calls with no screen |
| The task being implemented | its acceptance criteria name visual outcomes (a screen, a rendered element, a style) | its criteria name data, endpoints, or exit codes |

Rules:

- **Say the verdict and the evidence.** `UI — context.md Technology names
  Next.js + Tailwind` or `not applicable — a Go CLI, no render layer in
  Technology`.
- **`unknown` is not a verdict.** When `Technology` is still `unknown` (a fresh
  `plan-01` that discovered no stack) or the signals conflict, do not guess:
  **ask the user once**, plainly — "Does this app render a UI a user sees?" — and
  record the answer in `Applicability` as the evidence.
- **A missing `design.md` is never read as not-applicable.** Absence is the
  missing-artifact case, and it blocks (see the gate).

## Quality bar

- Every color is a **named, semantic token** with a value — never a bare hex
  sprinkled in prose. `--color-primary: #2563eb` beats "the buttons are blue".
- Every text/background pair used states its **contrast ratio**, and body text
  meets WCAG AA (4.5:1); large text and UI boundaries meet 3:1.
- Every interactive component names the states it supports, referencing
  `## States` rather than re-inventing them per component.
- Every non-obvious rule traces to a `## Sources` entry or is marked as derived.

## Anti-patterns

| Anti-pattern | Why it fails |
|---|---|
| A palette with no names | `/exec` cannot reuse it; each task re-picks colors. |
| A system copied verbatim from a licensed source without attribution | Legal and provenance failure; `## Sources` exists to prevent it. |
| Sections left as empty headings | `None` is the honest empty; a blank heading reads as "unfinished". |
| Per-plan design files | The whole point is one app-wide system; a second file is drift by construction. |
| Appending a revision log | Turns the snapshot into a changelog no reader can scan. |
