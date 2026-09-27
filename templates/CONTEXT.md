# Project Context

Read every session. One page. The detail lives in each plan's own
`specs/NN-<plan-slug>/spec.md`; this file is the memory that spans them.

## Project

{{App name, and one line identifying it.}}

## Purpose

{{The outcome this app exists to produce, in the user's terms.}}

## Target Users

{{The roles, one per line.}}

## Core Features

- {{Capability names, not descriptions. Grows as /plan adds features.}}
- {{Feature B}}
- {{Feature C}}

## User Flow

{{The primary journey as a compact numbered list, three to seven steps.}}

## Important Business Rules

{{The rules a later change could plausibly violate, one per line.}}

## Architecture

{{The shape: components, boundaries, data stores, external services. Three to six lines.}}

## Technology

{{The stack, one line per layer: language, framework, package manager, test runner, build tooling, database, deployment. Each entry names the file that proves it.}}

## Project Rules

{{This project's own conventions: branching, commit style, formatting, the commands to run before finishing. Facts backed by the repo or given by the user.}}

## Current Development Status

<!-- One line per plan folder, in this shape:
       - plan-NN — <plan slug> — <stage states> — <what that plan builds>
     Stage numbering restarts in every plan, so write that plan's own p0..pN.
     A plan with no slices yet reads "not sliced yet" in the state slot.
     The last clause summarises that plan's spec.md — it is what a reader uses
     to know what the project does without opening a spec, so never omit it.
     Past ~8 plan lines, collapse the oldest finished plans into a range.
     /plan writes the line; every later skill edits only the state slot. -->

- plan-01 — initial build — not sliced yet — {{the capabilities this plan delivers, one clause}}

{{N}} tasks total, 0 done.

## Important Decisions

{{Decisions taken, each with its reason, one line each. Do not reopen these.}}

## Known Constraints

{{Hard limits: budget, deadline, compliance, existing systems.}}

## Current Phase

PLAN

<!-- One of INIT, PLAN, SLICE, EXEC, REVIEW, CHECK, FIX. The skill that just ran
     writes its own name here. No task ID, no slice name, no free text. -->
