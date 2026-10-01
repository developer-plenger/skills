# Context — the context.md contract

`context.md` at the repo root is the file every later skill reads first, every session. It is the project's memory: one page saying what this app is, what its stack and conventions are, where its development stands, and which step of the chain last ran. `/init` creates it empty; `/plan` fills it; every skill keeps its status section current.

It is deliberately not a spec. Each plan owns its own specification at `specs/NN-<plan-slug>/spec.md`, and those specs are the full statement of intent; `context.md` is the one-page memory of the whole project, re-read on every single task. It is the only place that describes the project *across* plans — the specs each describe their own delta and cannot do that job.

## Why it is one page

The budget is one screen, counted rather than estimated: non-blank lines that are not headings — `grep -cvE '^[[:space:]]*$|^#' context.md` — staying at or under 60. `Current Development Status` is the one section allowed to grow, and only by one line per plan, because it is the section that answers what the project does; past roughly eight plan lines it condenses into finished ranges rather than pushing the file over. The reasoning: this file is read at the start of every `/slice`, `/exec`, `/review`, `/check` and `/fix` run, so its cost is paid on every task in the project. A file that triples in size to save someone a plan spec's lookup costs more than it saves. If a fact is needed to build one feature, it belongs in that plan's spec or slice file, not here.

When the file outgrows the budget, cut the least durable line. Never raise the budget. This is a trim trigger, not a hard cap: a genuinely dense project may sit above 60 honestly, provided every line still earns its place — but a file that needs 90 has turned into a changelog.

## The 14 sections, in order

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
## Project Rules
## Design
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
| Core Features | The capabilities, as a bullet list. Names, not descriptions. Grows as `/plan` adds features. | 3–10 bullets |
| User Flow | The primary journey as a compact numbered list. | 3–7 steps |
| Important Business Rules | The rules a later change could plausibly violate. | a few bullets |
| Architecture | The shape: components, boundaries, data stores, external services. | 3–6 lines |
| Technology | The stack, one line per layer: language, framework, package manager, test runner, build tooling, database, deployment. Each entry names the file that proves it. | one line per layer |
| Project Rules | This project's own conventions: branching, commit style, formatting, the commands to run before finishing — anything a skill needs that the pack's `AGENTS.md` does not carry. Facts backed by the repo or given by the user. | a few bullets |
| Design | A one-line pointer to the app-wide `design.md`: its applicability (UI or not applicable) and what it covers. Written by `/design`, not `/plan`. | 1 line |
| Current Development Status | The plan ledger and the project's actual state: one line per plan giving its identity, what it builds (compressed from that plan's `spec.md`), and its stage states — then the repository-wide task count. | 2–10 lines |
| Important Decisions | Decisions taken, each with its reason, one line each. Do not reopen these. | a few lines |
| Known Constraints | Hard limits: budget, deadline, compliance, existing systems. | a few bullets |
| Current Phase | One of the eight step names `INIT`, `PLAN`, `DESIGN`, `SLICE`, `EXEC`, `REVIEW`, `CHECK`, `FIX` — written by the skill that just ran, as its own name. No task ID, no free text. | one word |

## Current Development Status is the plan ledger

This is the section that answers "what does this project actually do right now?" without opening anything else. It carries **one line per plan**, and each line has four parts:

```markdown
## Current Development Status

- plan-01 — initial build — p0–p2 ✓ — expense entry, monthly total, correcting a past entry
- plan-02 — monthly budgets — p0 ✓ | p1 in progress — a budget per category, and spending shown against it
- plan-03 — CSV export — not sliced yet — expenses and a monthly summary exported as CSV

24 tasks total, 11 done.
```

| Part | Comes from | Example |
|---|---|---|
| **Plan identity** | the folder name in `specs/` | `plan-02 — monthly budgets` |
| **Stage states** | that plan's slice folders, derived from the checkboxes | `p0 ✓ \| p1 in progress` |
| **What it builds** | that plan's `spec.md`, compressed to one clause | `a budget per category, and spending shown against it` |

Rules for writing a line:

- **"What it builds" is a summary of that plan's `spec.md`, and it is mandatory.** Read §1 Overview, §3 Goals and §8 Functional Requirements and compress them to one clause naming the capabilities the user ends up with. Not a restatement of the plan title — `plan-02 — monthly budgets` says nothing on its own, while `a budget per category, and spending shown against it` says what the plan actually delivered. A plan whose line reads `- plan-02 — monthly budgets — p0 pending` is a line that failed to do its job.
- **Stage numbers restart per plan**, so write that plan's own sequence. `plan-02 — p0 … p1` is not a continuation of plan-01's, and the reader should not have to subtract a global counter.
- **`p0 ✓` means every task in stage `01-p0` has all three boxes checked.** It is the stage's state, not any one skill's verdict, so whichever skill flipped the last box that made that true writes it — `/exec`, `/review` and `/check` alike. A skill that moved no box leaves the line alone.
- **A plan with no slices yet reads `not sliced yet`** in the state slot. `/plan` writes that; `/slice` replaces it with the stage list.
- **The plan folder is the address.** `plan-02` names `specs/02-monthly-budgets/`, so a reader can open the spec behind any line.
- **One trailing line for the repository-wide task count** — `24 tasks total, 11 done.`

### Condensing, so the file stays one page

The section grows by one line per plan, so it needs a stated trim rule — otherwise a project with twelve plans has a twelve-line status section and the file stops being readable at a glance.

**Past roughly eight plan lines, collapse the oldest finished plans into a range:**

```markdown
- plan-01–plan-05 — done — expense entry and monthly totals, budgets, CSV export, recurring bills, shared accounts
- plan-06 — receipts — p0 ✓ | p1 in progress — a photo attached to an expense
- plan-07 — reports — not sliced yet — weekly and yearly summaries
```

The range line keeps all three parts: the plans it covers, `done` in the state slot, and the capabilities they delivered between them. Nothing is lost that a reader needs — the individual specs are still in their folders, and the range says which plan introduced what.

**Never delete a line to save space.** A finished plan's line is the record of what it delivered, and it is what stops a later `/plan` from re-specifying a feature that already exists. The only permitted compression is the finished range above.

## What earns a line

A fact is worth putting here if a later skill would otherwise have to re-derive it from the code, the spec, or the user — that is, if it is durable, project-level, and needed for ordinary decisions:

- The rule that decides a design question (a hard constraint, a non-negotiable).
- A decision already made, so it is not relitigated task after task.
- A status that tells a skill where in the chain the project is.

What does not earn a line: task-level detail, anything already in a slice file, any fact the pack's `AGENTS.md` already states, feature descriptions the spec covers at length, and anything that changed this week.

## Why project facts live here and not in AGENTS.md

`AGENTS.md` is the pack's registration file: it is the same in every project and carries no project content. Everything a skill used to read out of it — the stack, and the conventions to follow before finishing — belongs here instead, so there is one place a project's own facts are written and one owner for them. A skill that opens `AGENTS.md` expecting project facts is reading a stale mental model; `Technology` and `Project Rules` are where they live now.

## Update discipline

- **Rewrite the affected section, never append.** The file is a snapshot of what is currently true. An appended file is a changelog, and a changelog cannot be read at a glance.
- **Never let it become a changelog.** No dates except on decisions, no "previously we did X" narration, no per-task notes. If a change matters, the section now says the new truth and the task's own artifact carries the history.
- **`Core Features`, `User Flow` and `Important Business Rules` grow with `/plan`.** A later `/plan` that adds a feature adds to these sections rather than rewriting them, because the older features are still true. Everything else is rewritten in place.
- **`Current Development Status` is kept current by every skill that moves a box.** `/plan` adds the new plan's line — identity, `not sliced yet`, and the summary of what that plan builds — and `/slice` fills in the stage states. `/exec`, `/review`, `/check` and `/fix` update that plan's stage states and the task count. This is the one section besides `Current Phase` that is not `/plan`-owned, and `Current Development Status` is the only place `/slice` and the four later skills are allowed to write prose: they touch the state slot, never the summary clause.
- **`## Design` is `/design`-owned, not `/plan`'s.** It is a one-line pointer to the app-wide `design.md` and its applicability; `/design` writes it and rewrites it in place on a later run. `/plan` writes it as `unknown` and leaves it for `/design`, exactly as it leaves the plan specs' UI to `/design`. It is the only project section `/plan` does not own.
- **`Current Phase` reflects where the chain is, and after a skill runs that is the step it just completed — so every skill writes its own name.** `/init` writes `INIT`, `/plan` writes `PLAN`, `/design` writes `DESIGN`, `/slice` writes `SLICE`, `/exec` writes `EXEC`, `/review` writes `REVIEW`, `/check` writes `CHECK`, `/fix` writes `FIX`. The value is always exactly one of the eight names, so a parser can match it — never append a task ID, a note, or a "back to" clause. Which slice was being worked on goes in your report, not in this field.
- **Trim on write.** When an edit pushes the file past the counted budget, the same edit removes the least durable line.

## At the end of /init

Create the file if it is absent, with all 14 sections present and empty, and the cursor set:

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

## Project Rules

## Design

## Current Development Status

## Important Decisions

## Known Constraints

## Current Phase

INIT
```

`/init` asks the user nothing and inspects no code, so every section stays empty — there is no spec, no stack discovered, nothing to say. Empty means absent, not `unknown`: `/plan` is the run that fills it. If the file already exists, `/init` sets `Current Phase` to `INIT` and changes nothing else.

## At the end of /plan

On `plan-01`, fill 13 of the 14 sections from the spec and the stack-and-conventions discovery, each `Technology` and `Project Rules` entry naming its proving file or the answer that supplied it — a repository that proves neither gets `unknown`, never a guess. Leave `## Design` as `unknown`; it belongs to `/design`, the run that follows this one.

Every later `/plan` adds rather than replaces, because the earlier plans are still true:

- append the new feature names to `Core Features`, the new steps to `User Flow`, the new rules to `Important Business Rules`;
- add one line to `Current Development Status` for the new plan: its identity, `not sliced yet` for the state slot, and the one-clause summary of what this plan builds read off the spec you just wrote — no stage folders exist for it until `/slice` runs, so do not invent stage numbers;
- leave every older plan's line exactly where it is, and condense finished ranges only when the section has passed roughly eight plan lines.

Set `Current Phase` to `PLAN`, and create nothing under `specs/NN-<plan-slug>/` except `spec.md`. `slice/` belongs to `/slice`.

## At the end of /slice and later skills

Set `Current Phase` to the step that just ran.

- `/design` writes `## Design` — the pointer to the app-wide `design.md` and its applicability — and changes nothing else in the file.
- `/slice` replaces that plan's `not sliced yet` with the stages it produced, touching the state slot only: `plan-02 — monthly budgets — p0 pending | p1 pending — a budget per category, and spending shown against it`.
- `/exec`, `/review`, `/check` and `/fix` update that plan's stage states and the repository-wide task count.

Both touch the state slot and the count, and nothing else on the line. The summary clause stays as `/plan` wrote it — a later skill has no business rewriting what the plan delivers, and a summary edited by four skills is a summary nobody can trust.

Nothing else in the file changes. A skill working in `plan-02` never edits `plan-01`'s line.
