---
name: plan
description: >
  Turn a raw idea, a brief or a half-formed request into a written
  specification. Use for /plan, "/plan <idea>", "/plan <path to brief>", or
  whenever someone describes an app, feature or project and no
  docs/plan/SPEC.md exists for it yet. Critiques the idea through five
  lenses, asks only the questions that matter, records decisions, and
  writes docs/plan/SPEC.md and docs/plan/CONTEXT.md. The user never has to
  write a PRD first.
---

# Plan — raw idea to specification

`/plan` turns whatever the user has into two artifacts: `docs/plan/SPEC.md` — what will be built, in 19 sections — and `docs/plan/CONTEXT.md` — the one-page memory every later skill reads each session. The user is not expected to arrive with a PRD, and is not expected to have thought through their own idea. Finding the gaps is this skill's job.

Read `references/discovery.md` before step 3, `references/evaluation.md` before step 4, and `references/specification.md` plus `references/context.md` before step 8. Each holds a contract; none of the artifact formats live in this file.

## Steps

### 1. Read the context

In order: `AGENTS.md` at the repo root, `docs/plan/CONTEXT.md` if present, then the artifact being planned — the user's idea text, the brief file given as an argument, or the existing codebase if the idea lands on one. If `AGENTS.md` is missing, stop and tell the user to run `/init` first: without the operating context, later skills will not know the conventions this spec must respect.

If `docs/plan/SPEC.md` already exists, this is a revision, not a first draft. Say so, and change only the sections the new information touches.

**Done when:** you can state the idea in 2–3 sentences, name who asked for it and what already exists that it must fit with.

### 2. Understand the idea as stated

Write down what the user actually asked for, in their terms, before interpreting anything. Separate the request from your assumptions about it.

**Done when:** the user would recognise your restatement as their own words, and you have listed what you supplied that they did not say.

### 3. Extract requirements

Apply the extraction procedure in `references/discovery.md` to pull out the target user, features, workflow, data, integrations and constraints the idea implies. Where the idea lands on an existing codebase, read enough of it to know what the idea can build on and what it contradicts — the repo's real constraints beat the idea's imagined ones.

**Done when:** you have a draft requirements list where every entry is either sourced from the idea/repo/user, or flagged as your inference.

### 4. Critique through the five lenses

Run the idea through target user, features, development, security and scalability — the concrete questions and the weak-versus-strong signals are in `references/evaluation.md`. Challenge scope as you go: a feature with no user story behind it is a non-goal until the user justifies it, and an idea that cannot name its user is not ready to specify.

**Done when:** each lens has produced either a finding or an explicit "nothing to raise".

### 5. Route every finding

Each critique finding becomes exactly one of: a question to the user, a constraint in `SPEC.md` §16, or an explicit non-goal in §4. A finding that becomes none of these is a silent assumption, which is the one outcome not allowed.

**Done when:** every finding from step 4 has one of those three destinations, and none is unanswered.

### 6. Identify ambiguity

List what remains undecidable from the material — undefined actors, contradictory requirements, missing flows, unstated data ownership, unclear success criteria.

**Done when:** the list is complete enough that two competent engineers given the same material would still disagree on at least these points and no others you can find.

### 7. Ask the questions

Batch the ambiguity list into one round of questions using the rules in `references/discovery.md`: prioritise, cap, always offer your recommended answer, and never ask what the repo, the idea or the user's previous messages already answer. Ask about the decisions that change the shape of the spec; leave cosmetic choices for the user to overrule later.

**Done when:** every question that gates a section of `SPEC.md` has an answer from the user, or is recorded in §17 as still open.

### 8. Write the specification

Write `docs/plan/SPEC.md` following `references/specification.md`: all 19 sections, in order, each filled or explicitly `None`/`Unknown`. Number functional requirements `FR-001` onward, one per testable behaviour. Record only decisions actually taken in §18, each with its reason and the alternatives dropped. Write acceptance criteria in §19 so `/check` can turn each into pass/fail evidence. Park anything unresolved in §17 — never in an unnumbered aside inside another section.

Then write `docs/plan/CONTEXT.md` following `references/context.md`: all 12 sections, in order, within the one-page budget.

**Done when:** both files exist under `docs/plan/`, every section is filled or explicitly empty, every functional requirement is numbered and testable, and no unresolved question lives outside §17.

### 9. Update CONTEXT.md's phase

Set `Current Phase` to `PLAN` in `docs/plan/CONTEXT.md`. Leave `Current Development Status` describing actual state — no phases exist until `/slice` runs, so do not invent any.

**Done when:** `CONTEXT.md` reads `Current Phase: PLAN`.

### 10. Report

Tell the user: the two files written, the decisions taken in §18 and the alternatives dropped, what is still open in §17, and the next command — `/slice`.

**Done when:** the user knows what was decided, what remains open, and what to run next.
