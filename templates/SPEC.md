# Project Specification

The single source of truth for what gets built. Nineteen sections, in this order. `/plan` fills them in; `/slice` cuts them into phases.

## 1. Overview

One paragraph describing the product as a whole: what it is, who it is for, and what it replaces.

## 2. Problem Statement

The concrete problem today, and the cost of leaving it unsolved.

## 3. Goals

Outcomes, not deliverables; each measurable or observable, numbered `G-001` onward, capped at five.

## 4. Non-Goals

What this project explicitly will not do, so scope stays closed.

## 5. Target Users

Who uses the product, grouped by the situation that brings them there.

## 6. User Roles

The distinct permission levels or roles, and what each one is allowed to do.

## 7. User Stories

`As a <role from §6>, I want <goal>, so that <benefit>` — the "so that" is mandatory; numbered `US-001` onward.

## 8. Functional Requirements

Grouped per feature, each numbered `FR-001` onward and never renumbered: one testable behaviour stating trigger, behaviour, and result.

## 9. Business Logic

The rules, calculations, and state transitions the system enforces beyond simple CRUD.

## 10. User Flow

The primary paths a user takes through the product, step by step, including failure paths.

## 11. Technical Requirements

Stack, runtime targets, performance budgets, and any technical constraint the build must respect.

## 12. Security Requirements

Authentication, authorization, data protection, input handling, and what must never be logged or exposed.

## 13. Scalability Considerations

Expected load, growth assumptions, and the points where the design is expected to change first.

## 14. Data Requirements

Entities, key relationships, retention rules, and any migration or import obligation.

## 15. Integration Requirements

External services, APIs, or systems this product must talk to, and the contract for each.

## 16. Constraints

Fixed boundaries: budget, deadline, team size, licensing, platform, or technology that cannot change.

## 17. Open Questions

Unresolved questions that still block a decision, each with who can answer it.

## 18. Decisions

Resolved choices, each with the reasoning that settled it and the alternatives rejected.

## 19. Acceptance Criteria

The conditions that define the project as complete, stated so each one can be verified.
