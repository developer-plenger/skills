---
name: init
description: >
  Register the developer-plenger skill pack by writing AGENTS.md at the repo
  root — the pack's workflow, artifacts, skill rules and task-state contract —
  and create the empty context.md that every later skill updates. Use for
  /init, when onboarding a repository to the pack, or when AGENTS.md is
  missing or has drifted from the pack contract. Asks the user nothing and
  inspects no project facts; it does not create the project, pick a stack, or
  describe what the project is.
---

# Init — register the skill pack

`/init` writes two files at the repo root so every later skill knows which skills exist, what each one produces, where each artifact lives, and what the project currently is:

- `AGENTS.md` — the pack contract. Identical in every project; it is the pack's rules, not a description of the project.
- `context.md` — the project's memory, created **empty**: fourteen sections and nothing in them, because nothing has been planned yet and `/init` inspects nothing.

The run is: read what exists, compare it against the contract, write if it does not conform, report. `/init` asks the user nothing — there is no project-specific content to gather. It never inspects the codebase to infer a stack, a purpose or an architecture; those are project facts and belong to `/plan`, which records them in `context.md` and in `specs/NN-<plan-slug>/spec.md`.

Read `references/agents-template.md` before step 2 for the `AGENTS.md` contract — the canonical text, the conformance checklist, the merge rule for an existing file, and the `CLAUDE.md` dispositions. Read `skills/plan/references/context.md` before step 5 for the `context.md` shape that step writes.

## Steps

### 1. Read what already exists

Read, in this order, and only if present:

1. `AGENTS.md` at the repo root
2. `CLAUDE.md` at the repo root
3. `context.md` at the repo root

**Done when:** you know whether `AGENTS.md` exists, whether `context.md` exists, and whether a `CLAUDE.md` needs a disposition decision.

### 2. Compare AGENTS.md against the contract

Open `references/agents-template.md` §3 and check the existing file, section by
section, against the canonical text in §2. There is nothing to detect and nothing
to infer: the expected content is fixed, so this is a comparison.

If `AGENTS.md` is absent, this step is trivially "non-conformant" and you go
straight to writing it.

**Done when:** you can name every section that is missing or drifted, or state that none is.

### 3. Write AGENTS.md

- **Absent** — write the canonical text from `references/agents-template.md` §2
  verbatim.
- **Present and conformant** — write nothing.
- **Present and drifted or incomplete** — write the canonical version into place,
  following the merge rule in §4: never clobber content that is not a pack
  section, never reshuffle the user's own sections.

Never resolve a section by guessing project facts. Nothing in this file is
project-specific, so there is nothing to infer.

**Done when:** `AGENTS.md` at the repo root matches the contract, or was already matching.

### 4. Resolve CLAUDE.md, if present

If `CLAUDE.md` exists, apply the dispositions in `references/agents-template.md`
§4 and say plainly which file is canonical and whether the other becomes a
symlink or a short pointer. If it does not exist, do nothing here.

**Done when:** the user has been told which files you wrote, and — when a `CLAUDE.md` exists — which file is canonical and what happens to the other.

### 5. Create context.md, or reset its cursor

Follow `skills/plan/references/context.md` for the exact shape.

- **Absent** — write the fourteen sections, all empty, with `Current Phase` set to `INIT`. Empty means blank, not `unknown`: `/plan` is the run that fills this file, and a placeholder here invites a later skill to treat a guess as a fact.
- **Present** — set `Current Phase` to `INIT` and change nothing else. The project's facts belong to `/plan`.

Create no directory here. `specs/` is created by `/plan`, and a fresh clone should have no `specs/` tree until a plan is actually written.

**Done when:** `context.md` exists with the fourteen sections and `Current Phase: INIT`, or was already present with only its cursor changed.

### 6. Report

Tell the user: whether `AGENTS.md` was created, repaired, or already conformant; whether `context.md` was created or left in place; any non-pack content you preserved and where it belongs if it is still sitting in `AGENTS.md`; any decision taken about `CLAUDE.md`; and the next command to run — `/plan <idea>`.

**Done when:** the user knows the state of both files and what to run next.
