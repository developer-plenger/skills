# Context — the CONTEXT.md contract

`docs/plan/CONTEXT.md` is the file every later skill reads first, every session. It is a summary, not a second spec: `SPEC.md` is the full statement of intent and this is the memory of it.

## Why it is one page

The budget is one screen, counted rather than estimated: non-blank lines that are not headings — `grep -cvE '^[[:space:]]*$|^#' docs/plan/CONTEXT.md` — staying at or under 60. The reasoning: this file is read at the start of every `/slice`, `/exec`, `/review`, `/check` and `/fix` run, so its cost is paid on every single task in the project. A file that triples in size to save someone a `SPEC.md` lookup costs more than it saves. If a fact is needed to build one feature, it belongs in the spec and the phase file, not here.

When the file outgrows the budget, cut the least durable line. Never raise the budget. This is a trim trigger, not a hard cap: a genuinely dense project may sit above 60 honestly, provided every line still passes the "what earns a line" test below — but a file that needs 90 has turned into a changelog.

## What earns a line

A fact is worth putting here if a later skill would otherwise have to re-derive it from the code, the spec, or the user — that is, if it is durable, project-level, and needed for ordinary decisions:

- The rule that decides a design question (a hard constraint, a non-negotiable).
- A decision already made, so it is not relitigated task after task.
- A status that tells a skill where in the chain the project is.

What does not earn a line: task-level detail, anything already in a phase file, anything already in `AGENTS.md` verbatim, feature descriptions the spec covers at length, and anything that changed this week.

## The 12 sections, in order

```markdown
# Project Context

## Project
## Purpose
## Target Users
## Core Features
## User Flow
## Important Business Rules
## Architecture
## Technology
## Current Development Status
## Important Decisions
## Known Constraints
## Current Phase
```

| Section | Contents | Budget |
|---|---|---|
| Project | Name and one-line description. | 1–2 lines |
| Purpose | Why it exists, in the user's terms. | 1–3 lines |
| Target Users | The roles, one per line. | 1 line each |
| Core Features | The capabilities, as a bullet list. Names, not descriptions. | 3–8 bullets |
| User Flow | The primary journey as a compact numbered list. | 3–7 steps |
| Important Business Rules | The rules a later change could plausibly violate. | a few bullets |
| Architecture | The shape: components, boundaries, data stores, external services. | 3–6 lines |
| Technology | The stack, one line per layer. | one line per layer |
| Current Development Status | Which phases exist and how far along; the count of tasks by state. | 1–3 lines |
| Important Decisions | Decisions taken, each with its reason, one line each. | a few lines |
| Known Constraints | Hard limits: budget, deadline, compliance, existing systems. | a few bullets |
| Current Phase | One of the seven step names `INIT`, `PLAN`, `SLICE`, `EXEC`, `REVIEW`, `CHECK`, `FIX` — written by the skill that just ran, as its own name. No `TASK-NNN` suffix, no free text. | one word |

`Current Development Status` and `Current Phase` are the only sections every skill touches. The rest change when a decision or a constraint actually changes.

## Update discipline

- **Rewrite the affected section, never append.** The file is a snapshot of what is currently true. An appended file is a changelog, and a changelog cannot be read at a glance.
- **Never let it become a changelog.** No dates except on decisions, no "previously we did X" narration, no per-task notes. If a change matters, the section now says the new truth and the task's own artifact carries the history.
- **Keep the phase list in sync with the filesystem.** `Current Development Status` names the phases that exist under `docs/phases/`; when `/slice` adds or renames one, this line changes, and nothing else does.
- **`Current Phase` reflects where the chain is, and after a skill runs that is the step it just completed — so every skill writes its own name.** `/init` writes `INIT`, `/plan` writes `PLAN`, `/slice` writes `SLICE`, `/exec` writes `EXEC`, `/review` writes `REVIEW`, `/check` writes `CHECK`, `/fix` writes `FIX`. The two statements are the same one: the chain sits at the step that last ran. The value is always exactly one of the seven names in the table above, so a parser can match it — never append a task ID, a note, or a "back to" clause.
- **Trim on write.** When an edit pushes the file past the counted budget, the same edit removes the least durable line.

## At the end of /plan

Write the file fresh — created by this run — with all 12 sections filled from `SPEC.md`, and `Current Phase` set to `PLAN`. `Current Development Status` describes reality: no phase files exist yet, so say exactly that rather than inventing phase numbers.
