# Architecture

This repository is a skill pack, not an application. Its architecture is about where each kind of knowledge lives and which skill is allowed to write which file.

## Three layers

```text
skills/      agent behaviour      what the agent does, step by step
templates/   output shape         the skeletons artifacts are copied from
docs/        pack documentation   how the pack itself works and why
                                  (plus design-brief.md, the original brief: archived input, not documentation)
scripts/     pack integrity       the one check that catches silent drift
```

- `skills/<name>/SKILL.md` holds the procedure: the ordered steps an agent performs for that invocation. It is the only file the agent must load to run a skill.
- `skills/<name>/references/` holds the detailed formats and checklists the procedure pulls in on demand: the `spec.md` section list, the `context.md` shape, review checklists, dependency rules, task-state rules.
- `templates/` holds one copy-paste seed per produced artifact — all seven of them — for humans who want to see the shape before running anything.
- `scripts/` holds the pack's own test, which guards the invariants that break silently.
- `docs/` explains the workflow, this layout, and the state model to a human reader. One file there is not pack documentation: `docs/design-brief.md` is the original Indonesian design brief, kept for the reasoning behind the design and explicitly not a contract. Its provenance header names the places where it diverges from the shipped pack.

Nothing in `skills/` should be a copy of a template. The skill says which artifact to produce and when; the reference says exactly what shape it takes.

## Progressive disclosure

A `SKILL.md` must never inline a full template. Inlining means every invocation pays for the whole format even when the agent only needs the first two steps, and it means the format exists in two places that will drift apart.

The rule:

- `SKILL.md` — procedure: the steps, the order, the exit condition, the guards. Short enough to load unconditionally.
- `references/` — formats and checklists: loaded only at the step that needs them. A file with the exact section list of `spec.md` belongs here, not in the procedure.

For example, `skills/plan/SKILL.md` describes determining which plan this is, reading what already exists, critiquing the request, finding ambiguity, asking questions, and writing the plan. The nineteen-section format lives in `skills/plan/references/specification.md`, and the `context.md` contract — thirteen sections and the update discipline — in `skills/plan/references/context.md`. The same split applies to `slice` (vertical-slice and dependency rules), `exec` (implementation and completion), `review` (checklist and findings), `check` (testing and result recording), and `fix` (remediation).

## What lives where in a repository using the pack

```text
AGENTS.md                          pack contract, identical in every project
context.md                         the project's memory, one page, spans all plans
specs/
  01-initial-build/                a plan folder, created by its own /plan run
    spec.md                        that plan's 19-section specification (its delta)
    slice/01-p0/tasks.md           one development stage of that plan
    slice/02-p1/tasks.md
    reviews/TASK-003.md
    checks/TASK-003.md
    fixes/TASK-003.md
  02-monthly-budgets/              the next /plan run's folder
    spec.md
    slice/01-p0/tasks.md           its own p0 — stage numbering restarts per plan
```

**The plan folder is the unit of the design.** A `/plan` run is a plan, and a plan is a folder: `specs/NN-<plan-slug>/` holds the specification that plan was built from and every artifact its execution produced. Nothing about a plan lives outside its folder except one ledger line in `context.md`.

## Context mechanisms

Five mechanisms carry context, each answering a different question, each with one owner:

| Mechanism | Question it answers | Where it lives | Written by |
| --- | --- | --- | --- |
| `AGENTS.md` | How does the pack work — which skills exist, what each produces, where artifacts go? | project root | `/init` |
| `context.md` | What is this project across all its plans — its stack, its conventions, what it does, and where development stands? | project root | `/init` creates it, `/plan` fills it and writes each plan's summary clause, `/slice` and the four later skills keep the state slots current |
| Plan specs | What does *this* plan build? | `specs/NN-<plan-slug>/spec.md` | `/plan` |
| Slice files | What are this plan's development stages, and what do we do next? | `specs/NN-<plan-slug>/slice/NN-pK/tasks.md` | `/slice` |
| Checkboxes | What is already done? | inside the slice file | `/exec`, `/review`, `/check`, `/fix` |

The chain runs top to bottom: how the pack works, then what the project is, then what this plan builds, then what to do next, then what is finished.

### Why each plan gets its own spec

The obvious alternative is one specification that every `/plan` amends. That fails for three reasons, and each is worth naming because the pull toward the single spec is strong:

1. **A spec that is amended cannot be a record.** If `plan-02` overwrites §8, the requirement the user agreed to in `plan-01` is gone, and there is no way to tell whether a later surprise came from a mistaken plan or a mistaken edit.
2. **A growing spec becomes a document nobody reads.** By plan 05 the spec is a merge of five rounds of thinking, and no reader can tell which decision is still live.
3. **Amending means shared mutable state across runs.** Two plans cannot be planned in parallel, a plan cannot be abandoned without unpicking its edits, and every run has to read the whole accumulated document to avoid contradicting it.

Per-plan folders make each plan's spec immutable, small, and independently reviewable. The cost is that no single document states the app's current total requirements — that is `context.md`'s job at the level it can hold, and `specs/*/spec.md` read in order at the level it cannot.

`Current Development Status` closes most of that gap deliberately: each plan's line ends with a one-clause summary of what that plan's `spec.md` builds, so the section answers both "how far along is it" and "what does this project do" without opening a spec. The full requirement text still lives only in the plan specs — a summary is not a substitute for the document — but a reader who only needs orientation gets it from one file.

### Why a slice folder may hold its own records

Each plan's `reviews/`, `checks/` and `fixes/` sit beside its `slice/` rather than nested inside a stage folder. The stage folder already holds a task list; adding review, check and fix documents per task would make the path four or five levels deep for the common case. Flat beside `slice/` keeps `specs/02-monthly-budgets/reviews/TASK-003.md` short enough to type while still keeping every artifact inside the plan that produced it.

### Requirement and task IDs restart per plan

A plan folder is a namespace. `TASK-001` and `FR-001` restart inside every plan, because every artifact that cites them lives in the same folder: the spec that defines the requirement, the stage that implements it, and the review that checks it all sit under `specs/NN-<plan-slug>/`. Nothing has to be looked up across plans, and no numbering obligation spans a folder boundary.

The cost is real and worth stating: **a bare `TASK-NNN` no longer identifies a task.** Every invocation carries the plan — `/exec NN-<plan-slug>/NN-pK` — and each skill's step 2 asks which plan when the argument is ambiguous. The trade is deliberate: it buys a plan that can be read and worked on entirely on its own.

## Ownership map

Each artifact has exactly one owning skill. A skill that needs a change in someone else's artifact messages the human instead of editing it.

The exception is `context.md`, which is shared by design and split by field rather than by file. `Current Phase` has seven writers, because it is the workflow's cursor rather than project content. `Current Development Status` has six — `/plan` adds the new plan's line and its summary clause, `/slice` fills in the stages it produced, and `/exec`, `/review`, `/check` and `/fix` update that plan's stage states and the task count whenever they move a box. `/review` is in that list because flipping `Reviewed` can be the box that makes a stage `DONE`.

Inside that section the split is by part, not by line: the **state slot** belongs to whichever skill moved a box, the **summary clause** belongs to `/plan` alone. That is what keeps the clause trustworthy — it is the one piece of prose four other skills are forbidden to touch. The remaining eleven sections belong to `/plan` alone.

`AGENTS.md` is the only other file with any claim to being shared, and it is not: `/init` owns it and the other six skills read it.

| Artifact | Owned by | Read by |
| --- | --- | --- |
| `AGENTS.md` | `/init` | every skill |
| `context.md` (its eleven project sections) | `/plan` | every skill |
| `Current Phase` (a field inside `context.md`) | every skill, each setting it to its own step | every skill |
| `Current Development Status` (a section inside `context.md`) | `/plan` adds a line and writes its summary clause; `/slice`, `/exec`, `/review`, `/check`, `/fix` keep the state slots current, one plan's line at a time, and never rewrite the clause | every skill |
| `specs/NN-<plan-slug>/spec.md` | `/plan` | `/slice`, `/exec`, `/review`, `/check`, `/fix`, later `/plan` runs |
| `specs/NN-<plan-slug>/slice/NN-pK/tasks.md` | `/slice` | `/exec`, `/review`, `/check`, `/fix` |
| `specs/NN-<plan-slug>/reviews/TASK-NNN.md` | `/review` | `/fix` |
| `specs/NN-<plan-slug>/checks/TASK-NNN.md` | `/check` | `/fix` |
| `specs/NN-<plan-slug>/fixes/TASK-NNN.md` | `/fix` | `/review`, `/check` |

A plan folder's existence is `/plan`'s claim too: only `/plan` creates one, and only `/plan` chooses its number. `/slice` fills a folder's `slice/`, and never adds stages to a plan other than the one it was pointed at.

The skill that writes an artifact also creates that artifact's directory: `/plan` creates `specs/NN-<plan-slug>/` with its `spec.md`, `/slice` creates that plan's `slice/`, `/review` creates its `reviews/`, `/check` creates its `checks/`, and `/fix` creates its `fixes/`. `/init` creates no directory at all — a fresh clone has no `specs/` tree until the first `/plan` runs.

### Current Phase

`Current Phase` holds exactly one word, one of the seven step names:

```text
INIT | PLAN | SLICE | EXEC | REVIEW | CHECK | FIX
```

The skill that just ran sets it to its own step name, with no `TASK-NNN` suffix, no plan name and no stage name. `/init` leaves it at `INIT`, `/plan` moves it to `PLAN`, `/slice` to `SLICE`, `/exec` to `EXEC`, `/review` to `REVIEW`, `/check` to `CHECK`, `/fix` to `FIX`.

A value outside the enum — `FIX TASK-002, back to review`, or `EXEC 02-p1` — is a broken file, not a richer statement of position. The field stays parseable as one of seven words, and the plan, stage and task being worked on belong in the skill's report. This is why the field does not also carry coordinates: nothing that has to stay a closed enum can absorb free text.

Checkbox ownership is narrower than artifact ownership, because four skills write into the same slice file:

| Checkbox | Flipped by | Rule |
| --- | --- | --- |
| `Implemented` | `/exec` | only when the code actually runs |
| `Reviewed` | `/review` | only when no unresolved finding of Medium severity or higher remains |
| `Tested` | `/check` | only when every acceptance criterion has passing evidence |
| any of the three, to unchecked | `/fix` | resets exactly the boxes whose evidence its change invalidated |

`TASK-NNN`, `FR-NNN` and `US-NNN` all restart inside each plan folder; `FINDING-NNN` is numbered inside its own review document, so a full reference is `specs/02-monthly-budgets/reviews/TASK-003.md`'s `FINDING-001`, or `plan-02/TASK-003#FINDING-001` when the plan is not obvious from context. Plan IDs come from the folder name: `plan-02` is `specs/02-monthly-budgets/`, and the slug is part of the identity — two plans may share a number only if one was renamed by hand, which `check.sh` does not police and no skill does.

## templates/ versus references/

`templates/` mirrors the skeletons also described in the skills' `references/`. The two serve different readers:

- `references/` is what the agent loads at runtime. It is the normative format.
- `templates/` is a copy-paste seed for humans who want the shape in front of them.

If the two ever diverge, the `references/` files win — with one exception, `templates/AGENTS.md`, which must be byte-identical to the canonical text inside `skills/init/references/agents-template.md` because the whole point of that file is that it is the same in every project. `scripts/check.sh` enforces it. When a format changes, update the reference first, then re-copy the template; for `AGENTS.md`, re-extract the template from the reference's `~~~~markdown` block.

## scripts/

`scripts/check.sh` is the pack's only test, and it guards the invariants that break without anyone noticing: the canonical `AGENTS.md` text staying in sync with its template, a retired layout path not reappearing, a `SKILL.md` not linking a reference that was renamed, the artifact shapes keeping their section counts, and the vocabulary of the two retired models — many-apps-per-repository, and one-shared-spec-amended-by-every-plan — not creeping back. It needs `git`, `grep` and `python3` and nothing else — a pack that ships no dependency should not require one to check it.

It is deliberately not a linter. There is no rule about how a sentence is worded, because the pack's correctness is about paths, counts and one duplicated block, and a formatter would only add a tool to install.

## Why this layout

- One directory per skill keeps each behaviour independently loadable, so a `/check` invocation does not pay for `/plan`'s procedure.
- Splitting procedure from format is what lets a skill stay short while its output stays exact.
- One folder per plan is what makes a plan immutable, small and independently reviewable, and what lets the plan folders read in order as the app's history. The alternative — one spec amended forever — is discussed above, and it is the failure this structure exists to prevent.
- Putting the state in the slice file instead of a database means progress survives any tool, any session, and any review by a human reading the diff.
- Keeping the pack's own documentation in `docs/` keeps the root readable: a visitor sees the manifests, the skills, the templates, and a README that points here. Archived input like the design brief belongs there too, not beside the README, so the root never offers a second description of the system.
