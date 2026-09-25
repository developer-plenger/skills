---
name: init
description: >
  Register the developer-plenger skill pack by writing AGENTS.md at the repo
  root: the pack's workflow, artifacts, skill rules and task-state contract.
  Use for /init, when onboarding a repository to the pack, or when AGENTS.md
  is missing or has drifted from the pack contract. Asks the user nothing and
  inspects no project facts; it does not create the project, pick a stack, or
  describe what the project is.
---

# Init — register the skill pack

`/init` writes `AGENTS.md` at the repo root so every later skill knows which
skills exist, what each one produces, and where each artifact lives. The content
is the same in every project: it is pack contract, not a description of the
project.

The run is: read what exists, compare it against the contract, write if it does
not conform, report. `/init` asks the user nothing — there is no project-specific
content to gather. It never inspects the codebase to infer a stack, a purpose or
an architecture; those are project facts and belong to `/plan`, which records
them in `docs/plan/CONTEXT.md`.

Read `references/agents-template.md` before step 2. It holds the canonical text,
the conformance checklist, the merge rule for an existing file, and the
`CLAUDE.md` dispositions.

## Steps

### 1. Read what already exists

Read, in this order, and only if present:

1. `AGENTS.md` at the repo root
2. `CLAUDE.md` at the repo root
3. `docs/plan/CONTEXT.md`

**Done when:** you know whether `AGENTS.md` exists, and whether a `CLAUDE.md` needs a disposition decision.

### 2. Compare against the contract

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

### 5. Refresh CONTEXT.md if it exists

If `docs/plan/CONTEXT.md` exists, set its `## Current Phase` to `INIT`. Change
nothing else in that file — the rest of it belongs to `/plan`. If it does not
exist, leave it absent; `/plan` creates it.

**Done when:** `CONTEXT.md` either records `Current Phase: INIT` or was correctly left untouched.

### 6. Report

Tell the user: whether `AGENTS.md` was created, repaired, or already conformant;
any non-pack content you preserved and where it belongs if it is still sitting in
the file; any decision taken about `CLAUDE.md`; and the next command to run —
`/plan <idea>`.

**Done when:** the user knows the state of `AGENTS.md` and what to run next.
