---
name: plan
description: >
  Turn a raw idea, a brief or a half-formed request into a written
  specification for one plan. Use for /plan, "/plan <idea>", "/plan <path to
  brief>", or whenever someone describes work the app should do. Each run
  creates specs/NN-<plan-slug>/ — its own spec.md and its own slice/ folder —
  where the first run is the initial build and every later run is a feature.
  Critiques the request through five lenses, asks only the questions that
  matter, and records decisions. The user never has to write a PRD first.
---

# Plan — a request into one plan's specification

`/plan` turns whatever the user has into a plan: a folder `specs/NN-<plan-slug>/` holding a `spec.md` that states what **that plan** builds, and a `slice/` folder that `/slice` fills with the plan's development stages.

The first `/plan` is the initial build. Every later `/plan` is a feature, a fix to the requirements, or a piece of work the user wants specified before anyone writes code. Each one is its own numbered plan folder, with its own specification and its own slices, and `context.md` at the repo root is updated on every run so the project's memory always reflects what has been planned.

Read `references/discovery.md` before step 5, `references/evaluation.md` before step 6, and `references/specification.md` plus `references/context.md` before step 10. Each holds a contract; none of the artifact formats live in this file.

## Steps

### 1. Read the context

In order: `AGENTS.md` at the repo root, `context.md`, then the artifact being planned — the user's request, the brief file given as an argument, or the existing codebase.

If `AGENTS.md` is missing, stop and tell the user to run `/init` first. `context.md` tells you what the project already is: an empty one means this is the first `/plan` and there is nothing to build on; a filled one lists the plans that already exist and how far each has got.

**Done when:** you can state the request in 2–3 sentences, name who asked for it, and say whether any plan exists yet.

### 2. Determine which plan this is

Look at `specs/`. This step decides the plan's number and slug, and it is not a choice the user should have to make explicitly — read what is there and say which case you are in.

- **`specs/` does not exist, or holds no plan folder** — this is `plan-01`, the initial build. Its spec describes the product as a whole, because the first plan is the whole product.
- **Plan folders exist** — this is the next number. Take the highest `NN` under `specs/`, add one, and slug it from what *this* run adds — `plan-02-monthly-budgets`, `plan-03-csv-export`. A slug like `plan-03-update` is useless once there are four of them.

Plan numbers are append-only and never reused. Never renumber or rewrite an existing plan folder: `context.md`'s ledger, every slice folder and every review, check and fix document refer to plans by name.

**Done when:** you can name the plan number and slug, and say which case you are in — initial build, or a later feature.

### 3. Understand the request as stated

Write down what the user actually asked for, in their terms, before interpreting anything. Separate the request from your assumptions about it.

**Done when:** the user would recognise your restatement as their own words, and you have listed what you supplied that they did not say.

### 4. Read what already exists

This is the step that keeps the plan honest, and on a later plan it is the most valuable one. Read, and write down what you find:

1. `context.md` — especially `Core Features` and `Important Decisions`.
2. Every existing plan's `spec.md`. Read them all for `plan-01`, and the newest two or three for a later plan, looking at §4 Non-Goals, §7 User Stories, §8 Functional Requirements and §9 Business Logic.
3. The code, where the requested feature may already be partly built.

For each part of the request, decide one of four things, and say which:

- **Already there** — the feature exists as asked. Report it; the request is a misunderstanding, not a task.
- **Partly there** — an endpoint, table, helper or screen exists that this feature extends. Name it, and name the plan that introduced it; this plan reuses it rather than rebuilding.
- **Contradicted** — an earlier plan's decision or business rule says the opposite. Report the conflict; that plan's §18 is what the user agreed to, and changing it is this plan's §18 to record.
- **New ground** — nothing covers it.

The most common planning failure is rebuilding something that already exists a few files over, and this step is the only place it is cheap to catch.

**Done when:** every part of the request is classified, with the file or spec section that proves the classification.

### 5. Extract requirements

Apply the extraction procedure in `references/discovery.md` to pull out the target user, features, workflow, data, integrations and constraints the request implies. Where the request lands on existing code, read enough of it to know what it can build on and what it contradicts — the repo's real constraints beat the request's imagined ones.

This run also owns the project's own facts, because `AGENTS.md` no longer carries them. On `plan-01`, detect the stack and the conventions and record each with the file that proves it, for `context.md`'s `Technology` and `Project Rules` sections. On a later plan, check whether this request changes any of them — a new dependency, a new test runner, a database this feature introduces — and update those sections only where the fact changed.

**Done when:** you have a list of requirements where every entry is either sourced from the request/repo/user, or flagged as your inference, and — on `plan-01` — a stack-and-conventions list with a proving file or an answer behind each entry.

### 6. Critique through the five lenses

Run the request through target user, features, development, security and scalability — the concrete questions and the weak-versus-strong signals are in `references/evaluation.md`.

Challenge scope as you go, and challenge it harder on a later plan than on the first: a feature arrives with an app already built, so it must justify its own cost *and* the cost of changing what exists. A feature with no user story behind it is a non-goal until the user justifies it.

**Done when:** each lens has produced either a finding or an explicit "nothing to raise".

### 7. Route every finding

Each critique finding becomes exactly one of: a question to the user, a constraint in §16, or an explicit non-goal in §4. A finding that becomes none of these is a silent assumption, which is the one outcome not allowed.

**Done when:** every finding from step 6 has one of those three destinations, and none is unanswered.

### 8. Identify ambiguity

List what remains undecidable from the material — undefined actors, contradictory requirements, missing flows, unstated data ownership, unclear success criteria. On a later plan, add the questions the change raises about what already exists: whether an existing row needs backfilling, whether a new field is required for old records, whether changing a response breaks a caller.

**Done when:** the list is complete enough that two competent engineers given the same material would still disagree on at least these points and no others you can find.

### 9. Ask the questions

Batch the ambiguity list into one round of questions using the rules in `references/discovery.md`: prioritise, cap, always offer your recommended answer, and never ask what the repo, the earlier specs or the user's previous messages already answer. Ask about the decisions that change the shape of the plan; leave cosmetic choices for the user to overrule later.

**Done when:** every question that gates a section of this plan's spec has an answer from the user, or is recorded in §17 as still open.

### 10. Write the plan

Create the folder `specs/NN-<plan-slug>/`, then write two files.

**`specs/NN-<plan-slug>/spec.md`** — following `references/specification.md`: all 19 sections, in order, each filled or explicitly `None`/`Unknown`. The spec is **scoped to this plan**: §8 lists only the requirements this plan introduces, and a section this plan does not touch is `None` rather than a copy of an earlier plan's text. Number functional requirements `FR-001` onward **restarting per plan** — the plan folder is the namespace. Record only decisions actually taken in §18, each with its reason and the alternatives dropped. Park anything unresolved in §17.

**`context.md`** — following `references/context.md`. On `plan-01`, fill all 13 sections from the spec and the discovery, each `Technology` and `Project Rules` entry naming its proving file or the answer that supplied it — `unknown` where neither exists, never a guess. On a later plan, append the new feature names to `Core Features`, the new steps to `User Flow`, the new rules to `Important Business Rules`, and add this plan's line to `Current Development Status`; leave the older lines alone.

That line carries the one-clause summary of what this plan builds, read off the spec you just wrote — §1 Overview, §3 Goals, §8 Functional Requirements. It is the part of the file a reader relies on to know what the project does without opening a single spec, so `- plan-02 — monthly budgets — not sliced yet — a budget per category, and spending shown against it` is right and `- plan-02 — monthly budgets — not sliced yet` is not.

Do not create `slice/` here. `/slice` owns that folder and fills it; a plan with a spec and no slices yet is a normal, coherent state.

**Done when:** `specs/NN-<plan-slug>/spec.md` exists with every section filled or explicitly empty, every functional requirement is numbered and testable, no unresolved question lives outside §17, and `context.md` names this plan in `Current Development Status`.

### 11. Update the cursor

Set `Current Phase` to `PLAN` in `context.md`. The new plan's `Current Development Status` line reads `not sliced yet` in its state slot — no stage folders exist for it until `/slice` runs, so do not invent stage numbers — and carries its summary clause.

**Done when:** `context.md` reads `Current Phase: PLAN` and its ledger carries this plan's line.

### 12. Report

Tell the user: the plan folder and spec written, which plan this was and what it adds, the requirement IDs added, what already existed and was reused, the decisions taken in §18 and the alternatives dropped, what is still open in §17, and the next command — `/slice`.

**Done when:** the user knows what was specified, what remains open, and what to run next.
