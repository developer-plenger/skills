# Evaluation — the five critique lenses

`/plan` critiques the idea before specifying it. Critique here means finding what the idea gets wrong or leaves unsaid, not listing what is nice about it. Each lens below has concrete questions and a signal for what a weak versus strong answer looks like.

The rule that follows every lens: a finding becomes exactly one of —

1. a **question** to the user (it needs intent you do not have),
2. a **constraint** in `SPEC.md` §16 (it is a limit the design must respect), or
3. an explicit **non-goal** in §4 (it is deliberately out of scope).

A finding that becomes none of these is a silent assumption and must not ship. That is the single rule this reference exists to enforce.

## 1. Target user

Does the idea know who it is for, and does one product serve them?

Ask:

- Can the primary user be named as a role and a situation, not a demographic?
- Are all the roles named actually distinct, or is one role wearing three hats?
- Does each feature trace to a story from one of these users?
- Is the user already served by something they are happy with?
- What skill level is assumed, and what happens when the real user has less?

| Weak | Strong |
|---|---|
| "small businesses" | "a two-person shop where the owner is also the accountant" |
| "admins can do everything" | "owners approve spend; staff submit it and cannot see others' submissions" |
| a feature list no user asked for | each feature names the moment a user needs it |

## 2. Features

Is the set of features coherent, minimal, and complete enough to be usable?

Ask:

- Which single feature, if absent, makes the product pointless? Is it in scope?
- Which features are actually the same feature described twice?
- What is the day-one usable set, as opposed to the eventual set?
- For each feature: what does the user do before and after it? Are those steps present?
- Does any feature exist only because it is technically interesting?

**Scope challenge (mandatory).** A feature with no user story behind it is a non-goal until the user justifies it. State this plainly when it applies: put the feature in §4 Non-Goals with one line saying it has no user story, and let the user overrule. Silently including an unjustified feature inflates every phase that follows; silently deleting it loses something the user wanted.

| Weak | Strong |
|---|---|
| "users can manage their data" | "users can export a CSV and delete their account" |
| every feature marked core | a day-one set that is one coherent slice |
| non-goals absent or "everything else" | non-goals naming the adjacent features deliberately skipped |

## 3. Development

Can this be built by whoever asked, with what they have?

Ask:

- Is the stack fixed by the repo, the team, or preference — and does the idea respect it?
- Who maintains it, and does the design match their skill and time?
- Is the deadline compatible with the day-one feature set?
- What must exist alongside this — auth provider, CI, environments, a deploy target?
- What is the smallest end-to-end path that proves the idea works (the later tracer bullet)?
- Are there seeds of duplication with existing code that this will worsen?

| Weak | Strong |
|---|---|
| stack chosen for novelty | stack matches the repo and the maintainer |
| "then we build the frontend, backend, and infra" | one user journey buildable end to end first |
| deadline unmentioned | deadline stated and scope sized against it |

## 4. Security

This lens is not optional and its findings rarely become questions — most of them become requirements in §12.

Ask:

- What is the worst thing a malicious user could do, and who is closest to that ability?
- What data is sensitive, and where does it travel?
- Who may see and change each entity? Is that stated per role or assumed?
- How do users authenticate, and how do they recover access?
- What is logged, what is audited, and how long is it kept?
- What happens on failed login, repeated abuse, or a leaked credential?
- Where is the trust boundary — which side of it is the browser, the client, the third party?

| Weak | Strong |
|---|---|
| "auth later" | every route classified public or protected, with the check named |
| no mention of authorisation | roles mapped to resources and actions |
| secrets in the repo or in client code | secrets named and their storage location stated |

## 5. Scalability

Scalability is about the design surviving its own success, not about handling the internet on day one.

Ask:

- What are the realistic numbers — users, requests, records — in month one and month twelve?
- Which operations grow with data, and which stay constant?
- What breaks first: the database, a third-party limit, a file store, a long report?
- What runs synchronously that should be deferred, and vice versa?
- Is the scaling plan additive (more instances) or a rewrite (sharding, queues, caching)?
- What is acceptable downtime and latency, stated in numbers?

| Weak | Strong |
|---|---|
| "it will scale" | "list views paginate at 50; report runs as a background job" |
| no quantities anywhere | a named figure per limit, with the source of the figure |
| premature sharding and queues | the first bottleneck identified, with the fix deferred until it bites |

## Challenge scope while you work

Two habits, applied across all five lenses:

- **Ask who it is for.** An idea that cannot name its user is not ready to specify; send it back as a question rather than specifying it anyway.
- **Ask what it replaces.** A feature that duplicates existing behaviour, in this repo or in a service the user already pays for, is worth one question before it becomes a phase.
