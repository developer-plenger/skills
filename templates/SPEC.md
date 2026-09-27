# Specification — plan-{{NN}} {{plan title}}

<!-- Lives at specs/NN-<plan-slug>/spec.md, one per /plan run. It describes what
     THIS PLAN builds, not the whole app: a later plan's spec lists only the
     requirements it introduces, never a restatement of an earlier plan's.
     Nineteen sections, in this order. /slice cuts this plan into its own slices. -->

{{What this plan builds, in one or two sentences. Everything below is scoped to
this plan; a section this plan does not touch is `None`, not a copy of the
previous plan's text.}}

## 1. Overview

{{Three to six sentences: what THIS plan adds, who it is for, why now. On plan-01
this is the product as a whole; on every later plan it opens by saying what
already exists and what this run changes. No feature detail, no stack.}}

## 2. Problem Statement

{{The problem this plan solves, and the cost of leaving it unsolved. On a later
plan that is usually the gap the previous plans left.}}

## 3. Goals

{{Outcomes for this plan, not deliverables; each measurable or observable,
numbered `G-001` onward, capped at five. IDs restart per plan.}}

## 4. Non-Goals

{{What THIS plan deliberately leaves out, each with a one-line reason. The app's
total non-goal list is the union of every plan's §4.}}

## 5. Target Users

{{The user types this plan serves. When they are the same as an earlier plan's,
say so in one line and name that plan rather than repeating the description.}}

## 6. User Roles

{{The permission-bearing roles this plan touches, and what changes for each: a new
role, a new permission, or "unchanged from plan-01" with why this plan checked.}}

## 7. User Stories

{{`As a <role from §6>, I want <goal>, so that <benefit>` — the "so that" is
mandatory; numbered `US-001` onward, restarting per plan.}}

## 8. Functional Requirements

{{Only the requirements this plan introduces, grouped per feature, each numbered
`FR-001` onward and restarting per plan — a plan folder is the namespace. One
testable behaviour stating trigger, behaviour, and result. A requirement this
plan amends states the new behaviour and names the plan whose requirement it
replaces.}}

## 9. Business Logic

{{The rules this plan introduces or changes. When it changes a rule from an
earlier plan, state the new rule and say which plan's rule it supersedes.}}

## 10. User Flow

{{The paths this plan adds or alters, step by step, including failure paths.}}

## 11. Technical Requirements

{{The stack, runtime targets, performance budgets and technical constraints this
plan's work must respect — a new dependency, a migration, a budget this feature
must hit. Layers this plan does not touch are `None`.}}

## 12. Security Requirements

{{Authentication, authorization, data protection, input handling, and what must
never be logged or exposed, for what this plan touches. `None` when it touches
no trust boundary.}}

## 13. Scalability Considerations

{{Expected load for this plan's feature, the bottleneck it introduces, and the
stated response to it.}}

## 14. Data Requirements

{{The entities, fields, relationships, retention and migration obligations this
plan adds or changes. A new column states the backfill rule for existing rows and
whether old records stay valid.}}

## 15. Integration Requirements

{{External services this plan introduces or newly depends on, and the contract
for each. `None` when it adds none.}}

## 16. Constraints

{{Hard limits this plan must respect, including anything the earlier plans fixed
that this one cannot change.}}

## 17. Open Questions

{{Unresolved questions this plan leaves, each with its impact, your recommended
default, and whether a slice is blocked by it. A question you resolved belongs
in §18.}}

## 18. Decisions

{{Resolved choices in this plan, each with the reasoning that settled it and the
alternatives rejected.}}

## 19. Acceptance Criteria

{{The conditions that define THIS plan as complete, stated so each one can be
verified. `/check` turns each into evidence.}}
