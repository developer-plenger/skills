# Specification — the `spec.md` contract

Every plan owns one specification: `specs/NN-<plan-slug>/spec.md`. `NN` is the plan's number — `plan-01` is the first `/plan` run, `plan-02` the next — and the file describes **what that plan builds**, not the whole app.

That is the one rule this reference exists to enforce, and it has consequences for every section below.

## What a plan spec contains

A plan spec is **scoped to its own plan**. It carries the 19 sections, but each one answers "what does *this* plan require?" rather than "what does the app do?":

- **§8 Functional Requirements** lists only the requirements this plan introduces. Plan 02 does not restate plan 01's requirements, and does not renumber them.
- **§1 Overview** describes what this plan adds and where it lands in the app, in 3–6 sentences. It is not a re-description of the whole product — that lives in `plan-01` and in `context.md`.
- **§11 Technical Requirements** carries the technical constraints this plan's work must respect: a new dependency, a schema change, a performance budget this feature has to hit. A stack layer the plan does not touch is `None`.
- **§4 Non-Goals** names what this plan refused, not the app's total non-goal list.
- **§9 Business Logic**, **§10 User Flow**, **§14 Data Requirements** and **§15 Integration Requirements** carry what this plan adds or changes. When the plan changes existing behaviour, it states the new rule and says what it replaces — the earlier plan's spec is a historical record and is never edited to match.

Each plan spec is self-contained and independently reviewable. Reading `plan-03/spec.md` tells you everything plan 03 must do without reading plan 01 or 02. Reading all of them in order tells you the app's whole history, and `context.md`'s `Current Development Status` is the index into them.

## Plan specs are append-only

A plan spec is written once, by the `/plan` run that created it, and then only corrected in place — never rewritten to reflect a later plan's decisions. When plan 04 contradicts plan 02, plan 02's spec is not edited: plan 04's spec records the new decision, and `context.md`'s `Important Decisions` carries the current truth. A historical record that gets rewritten is not a record.

## The 19 sections, in order

The order is fixed: later sections reference earlier ones, and other skills index into them by number. Write every section; a section with nothing to say gets `None` (deliberately empty — this plan does not touch it) or `Unknown` (not yet decided, and then the same item appears in §17).

```markdown
# Specification — plan-NN <plan title>

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

The title names the plan — `# Specification — plan-03 CSV export` — so a file read on its own still says which plan it belongs to and what it was for. Without it, four specs in four folders all open with the same heading and the reader cannot tell which one they are looking at.

## Per-section fill rules

**1 Overview** — 3–6 sentences: what **this plan** adds, who it is for, why now. No feature detail, no stack. On `plan-01`, this is the product as a whole, because the first plan is the whole product; on every later plan, it opens by saying what already exists and what this run changes.

**2 Problem Statement** — the problem *this plan* solves, in the user's terms, plus what the app does today and why that falls short. On a later plan that is usually the gap the previous plans left. If the problem cannot be stated without describing the solution, the overview is doing the work and this section is empty — go back to the user.

**3 Goals** — outcomes for this plan, not deliverables. Each measurable or observable ("a user can export three years of expenses without the request timing out"). Cap at five; a longer list is a feature list wearing a goal's name. Number them `G-001` onward, restarting per plan.

**4 Non-Goals** — what **this plan** deliberately leaves out, each with a one-line reason. The app's total non-goal list is the union of every plan's §4, which is why each plan states its own refusals: a non-goal recorded only in the plan that made it stays honest about when it was decided.

**5 Target Users** — the user types this plan serves. Most later plans serve the same users as plan 01; when that is the case, say so in one line and name the plan that introduced them rather than repeating the description.

**6 User Roles** — the permission-bearing roles this plan touches, and what changes for each: a new role, a new permission, or "unchanged from plan-01" with the reason this plan needed to check. Roles with identical permissions are one role.

**7 User Stories** — `As a <role from §6>, I want <goal>, so that <benefit>.` The "so that" is mandatory: a story without a benefit is a task. Number them `US-001` onward, **restarting per plan** — plan 02 has its own `US-001`. Every story cites the role from §6, and every requirement in §8 traces to at least one story.

**8 Functional Requirements** — only the requirements this plan introduces, grouped under the feature they belong to, each numbered `FR-001` onward and **restarting per plan**. Each is one testable behaviour: state the trigger, the behaviour, and the result. A requirement that cannot be tested is not a requirement.

Numbering restarts because the plan folder is the namespace: `plan-02/spec.md`'s `FR-003` and `plan-01/spec.md`'s `FR-003` are different requirements in different documents, and a slice file always sits inside the plan whose spec it descends from. A requirement this plan *amends* states the new behaviour and names the plan whose requirement it replaces, rather than editing that plan's file.

**9 Business Logic** — the rules this plan introduces or changes: calculations, state transitions, constraint enforcement, precedence between rules, and what happens when they conflict. When it changes a rule from an earlier plan, state the new rule and say which plan's rule it supersedes.

**10 User Flow** — the numbered path this plan adds or alters, from entry point to outcome, including the error and empty-state branches that matter. Steps describe what the user does and sees, not what the system calls.

**11 Technical Requirements** — the stack, platform, performance targets with numbers, compatibility, environments and tooling **this plan's work must respect**. A new dependency, a migration, a budget this feature has to hit. Layers this plan does not touch are `None` — do not restate the stack to fill the section. The repo's real stack, when one exists, wins over the plan's imagined one.

**12 Security Requirements** — authentication, authorisation per role and resource, sensitive data handling, secrets, input validation at trust boundaries, audit and retention — **for what this plan touches**. A plan that adds an export has to answer what a user may export and what gets logged; a plan that only changes a label says `None`.

**13 Scalability Considerations** — the realistic numbers for this plan's feature (rows, requests, payload sizes), the bottleneck it introduces, and the stated response to it. Separate "we will design for this now" from "we will revisit this at a stated threshold".

**14 Data Requirements** — the entities, fields, relationships, retention and migration obligations this plan adds or changes. A later plan that adds a column states the backfill rule for existing rows and whether old records stay valid — that question is the reason this section exists per plan. Field-level schema belongs in the code and migration files, not here.

**15 Integration Requirements** — each external system this plan introduces or newly depends on: purpose, direction of data, auth method, failure behaviour, rate or contract limits, and who owns the credentials. An integration with no stated failure behaviour is an outage waiting for a date.

**16 Constraints** — hard limits this plan must respect: budget, deadline, team, legal, compliance, existing technology, hosting, contracts, and anything the earlier plans fixed that this one cannot change.

**17 Open Questions** — everything this plan leaves unresolved, one per line, each with the impact if answered one way versus another, your recommended default, and which section it would change. Say explicitly whether a slice is blocked by it. A question you resolved belongs in §18.

**18 Decisions** — only decisions actually taken in this plan, each as: the decision, the reason, the alternatives dropped, and the date. A preference you hold but the user has not agreed to is not a decision. This is the audit trail later plans and skills read before proposing changes.

**19 Acceptance Criteria** — one per goal or requirement group **in this plan**, each phrased so a test can pass or fail it. `/check` turns each into evidence. An acceptance criterion with no observable action is a wish, not a criterion.

## Quality bar

- Every functional requirement has a unique number *within this plan*, a trigger, an observable result, and a test that could fail it.
- Every user story has a role from §6 and a benefit clause.
- Every acceptance criterion names the thing observed and the condition for passing.
- Every open item lives in §17 and nowhere else.
- Every decision in §18 names what was dropped in exchange.
- Every section that describes the app rather than the plan's delta says so explicitly, and points at the plan that owns the description.

## Anti-patterns

| Anti-pattern | Why it fails | Fix |
|---|---|---|
| A later plan's §8 restating plan 01's requirements | two documents claim the same requirement; a slice can no longer say which spec it descends from | list only what this plan introduces; reference the earlier plan by name |
| Sections left as a copy of the previous plan's | the spec stops being a delta and becomes a stale duplicate of a document that already exists | `None` for what this plan does not touch |
| "should be fast", "must be easy to use", "robust" | not testable; `/check` can produce no evidence | name the metric: page under 1s at p95 on the stated hardware; error message names the field and the fix |
| Requirement restating the feature name — "FR-003: user search" | states a label, not a behaviour | "FR-003: given a query of two or more characters, return matching users ordered by relevance, capped at 20" |
| Open question written as a requirement — "FR-007: support SSO probably" | ships ambiguity into implementation | move to §17 with the default and impact |
| Goal that is a deliverable — "G-002: build the dashboard" | nothing to accept or reject at the end | "G-002: a manager can see team progress without asking anyone" |
| Role with no story, or story with an invented role | roles and stories disagree | reconcile before writing §8 |
| Decision recorded without its dropped alternative | later readers cannot judge whether to revisit | add the alternative and why it lost |
| §4 empty because "nothing is out of scope" | scope creep has no written defence | name the adjacent features deliberately skipped |
| Numbers appearing for the first time in §19 | acceptance criteria test things no requirement asked for | trace every criterion back to a goal or requirement |
| Editing an earlier plan's spec to match this one | the historical record stops being a record, and the plan ledger in `context.md` now describes documents that never said that | leave it; record the change in this plan's §18 |
