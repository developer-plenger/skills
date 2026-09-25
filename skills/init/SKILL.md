---
name: init
description: >
  Prepare a project's AI operating context for /init: detect the stack,
  tooling and existing docs, infer the project's purpose, users, features
  and architecture, ask only what cannot be inferred, then write AGENTS.md
  at the repo root and register the plan → slice → exec → review ∥ check →
  fix workflow. Use when onboarding an existing codebase, or when AGENTS.md
  is missing or stale; it does not create the project.
---

# Init — prepare the AI operating context

`/init` makes a project legible to every later skill in this pack. It writes `AGENTS.md` at the repo root, registering the end-to-end workflow inside it, and when `docs/plan/CONTEXT.md` already exists it refreshes that file's `Current Phase` as well. It never creates project code, never picks a stack, never scaffolds directories.

Read `references/agents-template.md` before step 2. It holds the four contracts this skill enforces: the `AGENTS.md` section-by-section shape, the detection checklist, the merge rule for existing files, and the evidence rule.

## Steps

### 1. Read what already exists

Read, in this order, and only if present:

1. `AGENTS.md` at the repo root
2. `docs/plan/CONTEXT.md`
3. `CLAUDE.md` at the repo root

An existing `AGENTS.md` means this is a refresh, not an authoring pass: its content is preserved unless the user explicitly says otherwise. `CONTEXT.md` may be absent — `/plan` owns creating it, this skill only refreshes it if it already exists.

**Done when:** you know whether this is a first run or a refresh, and, for a refresh, which sections already exist and which must be added.

### 2. Detect the project

Work through the detection checklist in `references/agents-template.md`: languages, frameworks, package manager, test runner, build tooling, existing docs, existing agent-context files, git presence.

**Done when:** every detected fact names the file that proves it — e.g. "Vitest, proven by `vitest.config.ts` and the `test` script in `package.json`".

### 3. Inspect before inferring

Read the entry points, configuration, README and any docs directory; skim the source tree for structure. From this evidence, draft statements for the project's purpose, target users, features, technology and architecture.

**Done when:** each of those five has a draft statement backed by a file you read, or is marked `unknown`.

### 4. Resolve the existing-file question

If `AGENTS.md` or `CLAUDE.md` already exists, apply the merge rule from the reference: never clobber the user's file, fold the pack's sections into it, and preserve everything already written there. If `CLAUDE.md` exists, say plainly which file will be canonical and whether the other should be a symlink or a duplicate — and why.

**Done when:** the user has been told exactly which files you will write and whether any existing content moves.

### 5. Ask only what cannot be inferred

Ask for the remaining gaps in a single batch, capped at about seven questions, each with your recommended answer so the user can confirm or correct. Typical gaps: purpose, target users, the feature that matters most, deployment target, hard constraints, and anything already marked `unknown`. Never ask what a file you read, the README, or the user's own message already answers.

**Done when:** every question you asked is one you could not have answered from the repo or the request.

### 6. Write AGENTS.md

Fill every section from `references/agents-template.md`, in its order, with the project's real content. Every claim traces to a file you read or to an answer the user gave; mark the rest `unknown` rather than guessing. Register all seven skill rules — one `###` per skill — plus the artifacts table listing the seven artifact paths and the Task State rule.

**Done when:** `AGENTS.md` exists at the repo root, no section is missing, and a reader can name every artifact path and the skill that owns it.

### 7. Refresh CONTEXT.md if it exists

If `docs/plan/CONTEXT.md` exists, set its `Current Phase` to `INIT` and, if the phase list changed, update its `Current Development Status`. If it does not exist, leave it absent — `/plan` creates it.

**Done when:** `CONTEXT.md` either records `Current Phase: INIT` or was correctly left untouched.

### 8. Report

Tell the user: the file written, every section still marked `unknown` and why, any decision taken about `CLAUDE.md`, and the next command to run — `/plan <idea>`.

**Done when:** the user knows what was written, what is still unknown, and what to run next.
