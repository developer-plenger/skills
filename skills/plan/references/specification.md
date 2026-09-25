# Specification — the SPEC.md contract

`docs/plan/SPEC.md` has 19 sections, in this order. The order is fixed: later sections reference earlier ones, and later skills index into them by number. Write every section; a section with nothing to say gets `None` (deliberately empty) or `Unknown` (not yet decided, and then the same item appears in §17).

```markdown
# Project Specification

## 1. Overview
## 2. Problem Statement
## 3. Goals
## 4. Non-Goals
## 5. Target Users
## 6. User Roles
## 7. User Stories
## 8. Functional Requirements
## 9. Business Logic
## 10. User Flow
## 11. Technical Requirements
## 12. Security Requirements
## 13. Scalability Considerations
## 14. Data Requirements
## 15. Integration Requirements
## 16. Constraints
## 17. Open Questions
## 18. Decisions
## 19. Acceptance Criteria
```

## per-section fill rules

**1 Overview** — 3–6 sentences: what this is, who it is for, why now. No feature detail, no stack. A reader who stops here should know what product they are looking at.

**2 Problem Statement** — the problem in the user's terms, plus what they do today and why that falls short. If the problem cannot be stated without describing the solution, the overview is doing the work and this section is empty — go back to the user.

**3 Goals** — outcomes, not deliverables. Each goal measurable or observable ("a first-time user completes signup without support"). Cap at five; a longer list is a feature list wearing a goal's name. Number them `G-001` onward.

**4 Non-Goals** — what is deliberately out of scope, each with a one-line reason. Non-goals are the cheapest defence against scope creep later; an empty section here usually means the scope challenge was skipped.

**5 Target Users** — one entry per user type: who they are, what they need, how often they use this. The lens-1 critique from `evaluation.md` lands here.

**6 User Roles** — the permission-bearing roles, one per line: name, what they can do, what they cannot. Roles with identical permissions are one role. Every role named elsewhere in the spec must appear here, and nothing here should be invented without a story behind it.

**7 User Stories** — `As a <role from §6>, I want <goal>, so that <benefit>.` The "so that" is mandatory: a story without a benefit is a task, and belongs in a phase file. Number them `US-001` onward. Every story cites the role from §6, and every feature in §8 traces to at least one story.

**8 Functional Requirements** — grouped under the feature they belong to, each numbered `FR-001` onward, globally and never renumbered once written. Each requirement is one testable behaviour. State the trigger, the behaviour, and the result; a requirement that cannot be tested is not a requirement.

**9 Business Logic** — the rules that hold regardless of implementation: calculations, state transitions, constraint enforcement, precedence between rules, and what happens when they conflict. This is where "the discount cannot exceed the margin" lives.

**10 User Flow** — the numbered path for each primary journey, from entry point to outcome, including the error and empty-state branches that matter. Steps describe what the user does and sees, not what the system calls.

**11 Technical Requirements** — stack, platform, performance targets with numbers, compatibility, environments, tooling. Anything the implementation must respect, expressed so it can be verified. The repo's real stack, when one exists, wins over the idea's imagined stack.

**12 Security Requirements** — authentication, authorisation per role and resource, sensitive data handling, secrets, input validation at trust boundaries, audit and retention, and the response to the misuse cases from lens 4. Each item is a requirement, not a worry.

**13 Scalability Considerations** — the realistic numbers (month one, month twelve), the known bottleneck, and the stated response to it. Separate "we will design for this now" from "we will revisit this at a stated threshold".

**14 Data Requirements** — entities and their relationships, ownership and sources of truth, retention and deletion, migration needs, validation rules. A one-line relationship list or a small diagram; the field-level schema belongs in the code and migration files, not here.

**15 Integration Requirements** — each external system: purpose, direction of data, auth method, failure behaviour, rate or contract limits, and who owns the credentials. An integration with no stated failure behaviour is an outage waiting for a date.

**16 Constraints** — hard limits the design must respect: budget, deadline, team, legal, compliance, existing technology, hosting, contracts. This is where the lens-3 findings from `evaluation.md` land, and where the repo's discovered constraints go.

**17 Open Questions** — everything still unresolved at the end of planning, one per line, each with the impact if answered one way versus another, your recommended default, and which section it would change. A question you resolved belongs in §18, not here. Zero open questions is acceptable; an open question hidden in another section is not.

**18 Decisions** — only decisions actually taken, each as: the decision, the reason, the alternatives dropped, and the date. A preference you hold but the user has not agreed to is not a decision. This section is the audit trail later skills read before proposing changes.

**19 Acceptance Criteria** — one per goal or requirement group, each phrased so a test can pass or fail it. `/check` will turn each into evidence. An acceptance criterion with no observable action is a wish, not a criterion.

## Quality bar

- Every functional requirement has a unique number, a trigger, an observable result, and a test that could fail it.
- Every user story has a role from §6 and a benefit clause.
- Every acceptance criterion names the thing observed and the condition for passing.
- Every open item lives in §17 and nowhere else.
- Every decision in §18 names what was dropped in exchange.

## Anti-patterns

| Anti-pattern | Why it fails | Fix |
|---|---|---|
| "should be fast", "must be easy to use", "robust" | not testable; `/check` can produce no evidence | name the metric: page under 1s at p95 on the stated hardware; error message names the field and the fix |
| Requirement restating the feature name — "FR-003: user search" | states a label, not a behaviour | "FR-003: given a query of two or more characters, return matching users ordered by relevance, capped at 20" |
| Open question written as a requirement — "FR-007: support SSO probably" | ships ambiguity into implementation | move to §17 with the default and impact |
| Goal that is a deliverable — "G-002: build the dashboard" | nothing to accept or reject at the end | "G-002: a manager can see team progress without asking anyone" |
| Role with no story, or story with an invented role | roles and stories disagree | reconcile before writing §8 |
| Decision recorded without its dropped alternative | later readers cannot judge whether to revisit | add the alternative and why it lost |
| §4 empty because "nothing is out of scope" | scope creep has no written defence | name the adjacent features deliberately skipped |
| Numbers appearing for the first time in §19 | acceptance criteria test things no requirement asked for | trace every criterion back to a goal or requirement |
