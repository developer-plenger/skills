# Architecture

This repository is a skill pack, not an application. Its architecture is about where each kind of knowledge lives and which skill is allowed to write which file.

## Three layers

```text
skills/      agent behaviour      what the agent does, step by step
templates/   output shape         the skeletons artifacts are copied from
docs/        pack documentation   how the pack itself works and why
                                  (plus design-brief.md, the original brief: archived input, not documentation)
```

- `skills/<name>/SKILL.md` holds the procedure: the ordered steps an agent performs for that invocation. It is the only file the agent must load to run a skill.
- `skills/<name>/references/` holds the detailed formats and checklists the procedure pulls in on demand: the `SPEC.md` section list, review checklists, dependency rules, task-state rules.
- `templates/` holds one copy-paste seed per produced artifact — all seven of them, including `FIX.md` — for humans who want to see the shape before running anything.
- `docs/` explains the workflow, this layout, and the state model to a human reader. One file there is not pack documentation: `docs/design-brief.md` is the original Indonesian design brief, kept for the reasoning behind the design and explicitly not a contract. Its provenance header names the places where it diverges from the shipped pack.

Nothing in `skills/` should be a copy of a template. The skill says which artifact to produce and when; the reference says exactly what shape it takes.

## Progressive disclosure

A `SKILL.md` must never inline a full template. Inlining means every invocation pays for the whole format even when the agent only needs the first two steps, and it means the format exists in two places that will drift apart.

The rule:

- `SKILL.md` — procedure: the steps, the order, the exit condition, the guards. Short enough to load unconditionally.
- `references/` — formats and checklists: loaded only at the step that needs them. A file with the exact section list of `SPEC.md` belongs here, not in the procedure.

For example, `skills/plan/SKILL.md` describes understanding the idea, critiquing it, finding ambiguity, asking questions, and writing the two documents. The nineteen-section format lives in `skills/plan/references/specification.md`, and the twelve-section format lives in `skills/plan/references/context.md`. The same split applies to `slice` (vertical-slice and dependency rules), `exec` (implementation and completion), `review` (checklist and findings), `check` (testing and result recording), and `fix` (remediation).

## Context mechanisms

Five mechanisms carry context, each answering a different question, each with one owner:

| Mechanism | Question it answers | Where it lives | Written by |
| --- | --- | --- | --- |
| `AGENTS.md` | How does the agent work in this project? | project root | `/init` |
| `CONTEXT.md` | What is this project? | `docs/plan/CONTEXT.md` | `/plan`, plus every skill writing the `Current Phase` cursor |
| `SPEC.md` | What must be built? | `docs/plan/SPEC.md` | `/plan` |
| Phase files | What do we do next? | `docs/phases/phase-NN-<slug>.md` | `/slice` |
| Checkboxes | What is already done? | inside the phase file | `/exec`, `/review`, `/check`, `/fix` |

The chain runs top to bottom: how to work, then what the project is, then what to build, then what to do, then what is finished.

`AGENTS.md` is deliberately not documentation for humans only. It is the file every other skill reads before acting, so it carries the workflow registration and the per-skill rules. `CONTEXT.md` is deliberately short and re-read every session, so the agent never has to load the whole spec to remember what the product is.

## Ownership map

Each artifact has exactly one owning skill. A skill that needs a change in someone else's artifact messages the human instead of editing it.

The one exception is the `Current Phase` field of `docs/plan/CONTEXT.md`. Every skill sets it to its own step name, because it is the workflow's shared cursor rather than project content. That single field has seven writers; the rest of `CONTEXT.md` still belongs to `/plan` alone, which is why the table records `/plan` as the document's owner. `AGENTS.md` is the only other file with any claim to being shared, and it is not: `/init` owns it and the other six skills read it.

The skill that writes an artifact also creates that artifact's directories: `/plan` creates `docs/plan/`, `/slice` creates `docs/phases/`, `/review` creates `docs/reviews/`, `/check` creates `docs/checks/`, and `/fix` creates `docs/fixes/`. `/init` creates none of them, so a fresh clone has no `docs/` tree until `/plan` runs.

| Artifact | Owned by | Read by |
| --- | --- | --- |
| `AGENTS.md` | `/init` | every skill |
| `docs/plan/SPEC.md` | `/plan` | `/slice`, `/exec`, `/review` |
| `docs/plan/CONTEXT.md` | `/plan` | every skill |
| `docs/phases/phase-NN-<slug>.md` | `/slice` | `/exec`, `/review`, `/check`, `/fix` |
| `docs/reviews/TASK-NNN.md` | `/review` | `/fix` |
| `docs/checks/TASK-NNN.md` | `/check` | `/fix` |
| `docs/fixes/TASK-NNN.md` | `/fix` | `/review`, `/check` |
| `Current Phase` (a field inside `CONTEXT.md`) | every skill, each setting it to its own step | every skill |

### Current Phase

`Current Phase` holds exactly one word, one of the seven step names:

```text
INIT | PLAN | SLICE | EXEC | REVIEW | CHECK | FIX
```

The skill that just ran sets it to its own step name, with no `TASK-NNN` suffix. `/plan` leaves it at `PLAN`, `/slice` moves it to `SLICE`, `/exec` to `EXEC`, `/review` to `REVIEW`, `/check` to `CHECK`, `/fix` to `FIX`. A value outside the enum — `FIX TASK-002, back to review` and the like — is a broken file, not a richer statement of position. Because every skill writes this field and nothing else in the file, it is the workflow's cursor: naming the step just completed is the same statement as saying where the chain is.

Checkbox ownership is narrower than artifact ownership, because four skills write into the same phase file:

| Checkbox | Flipped by | Rule |
| --- | --- | --- |
| `Implemented` | `/exec` | only when the code actually runs |
| `Reviewed` | `/review` | only when no unresolved finding of Medium severity or higher remains |
| `Tested` | `/check` | only when every acceptance criterion has passing evidence |
| any of the three, to unchecked | `/fix` | resets exactly the boxes whose evidence its change invalidated |

Global task IDs (`TASK-001`) are allocated by `/slice` and never reused. Review findings are numbered inside their own document (`FINDING-001` in `docs/reviews/TASK-003.md`) and referenced as `TASK-003#FINDING-001`. Phase IDs come from the filename: `phase-01`, `phase-02`.

## templates/ versus references/

`templates/` mirrors the skeletons also described in the skills' `references/`. The two serve different readers:

- `references/` is what the agent loads at runtime. It is the normative format.
- `templates/` is a copy-paste seed for humans who want the shape in front of them.

If the two ever diverge, the `references/` files win. When a format changes, update the reference first, then re-copy the template.

## Why this layout

- One directory per skill keeps each behaviour independently loadable, so a `/check` invocation does not pay for `/plan`'s procedure.
- Splitting procedure from format is what lets a skill stay short while its output stays exact.
- Putting the state in the phase file instead of a database means progress survives any tool, any session, and any review by a human reading the diff.
- Keeping the pack's own documentation in `docs/` keeps the root readable: a visitor sees the manifests, the skills, the templates, and a README that points here. Archived input like the design brief belongs there too, not beside the README, so the root never offers a second description of the system.
