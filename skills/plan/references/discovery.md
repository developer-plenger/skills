# Discovery — reading the idea, and asking about the rest

How `/plan` gets from an unstructured idea to a requirements list, and how it asks the questions that cannot be answered from the material.

## 1. Reading an unstructured idea

An idea is rarely complete. Extract in this order, because each layer constrains the next:

1. **The actor** — who performs the action the idea describes? "An app to track expenses" names no actor; "freelancers tracking deductible expenses" does.
2. **The trigger** — what makes the actor reach for this? A moment, not a feature.
3. **The outcome** — what is true after they use it that was not true before.
4. **The workflow** — the numbered steps from trigger to outcome. This becomes §10 User Flow.
5. **The data** — what must be stored for the outcome to hold; who owns it and who may see it.
6. **The boundaries** — what the idea explicitly is not, and what it would need in order to be that.

For each extracted item, tag the source: `[idea]`, `[repo]`, `[user]`, or `[inference]`. An `[inference]` becomes a question if it gates a SPEC section, and a stated assumption otherwise.

Things to be suspicious of in the idea text:

- Feature lists where a workflow should be — the user has jumped to solutions.
- "AI-powered", "modern", "scalable", "simple" — adjectives describing a feeling, not behaviour.
- Plural nouns with no boundary: "users", "admins", "customers" — how many roles really exist?
- A single-actor idea with team-shaped requirements, or vice versa.
- Anything that presupposes an integration the user has not named.

## 2. The question bank, by lens

Draw from these when a section of `SPEC.md` would otherwise be blank. Not all apply to every idea; ask the ones that gate a decision.

**Target user**

- Who exactly uses this — one role, or several with different needs?
- What do they use today instead, and what is wrong with it?
- How often do they do this, and what makes it painful?
- Who else is affected by their use — approvers, customers, downstream teams?
- Is the primary user inside the organisation, outside it, or both?

**Features**

- What is the one action the product must get right, the day one feature?
- What is in scope for the first usable version, and what can wait?
- What happens when the user makes a mistake — edit, undo, retry?
- What does the product do with the user's data over time — accumulate, expire, export?
- Which of these features has no user story behind it?

**Development**

- What stack, if any, is already fixed — by team, by existing repo, by the user?
- Who maintains this after launch, and what do they know?
- What is the deadline, and what is driving it?
- What existing system must this live alongside?
- What is the deployment target — a laptop, a server, a cloud platform, an app store?

**Security**

- What is the worst-case misuse, and who would do it?
- What data is sensitive — personal, financial, health, credentials?
- Who is allowed to see and change what?
- What is the account lifecycle — signup, recovery, removal, handover?
- What must be audited, and how long must records live?

**Scalability**

- How many users and actions in the first month, and how much growth is plausible?
- What is the concurrency — a few heavy users, or many light ones?
- What is the data volume over a year?
- What has to stay fast, and what is allowed to be slow?
- What fails first under load, and what should happen then?

**Data**

- What are the core entities and their relationships?
- What is the source of truth for each data set?
- What must be retained, and what must be deletable on request?
- What has to migrate in, and who owns that migration?
- What happens to the data if the product is discontinued?

**Integration**

- What external services are mandatory versus nice to have?
- What are the auth and failure modes of each, and who holds the credentials?
- What contractual or rate limits apply?
- If an integration is down, does the product degrade or stop?
- What data crosses the boundary, and in which direction?

**Constraints**

- Hard deadlines, budget ceilings, legal or compliance requirements?
- Existing technology the team will not replace?
- People available, and their availability?
- Anything the user considers out of bounds regardless of engineering merit?

## 3. Rules for asking

- **Batch.** One round of questions, not a dialogue. Batch to at most about seven; rank them so the user can stop answering and still leave the spec coherent.
- **Prioritise.** Ask what changes the shape of the spec, not what changes a detail you can revise later.
- **Recommend.** Every question carries your default ("we will assume single-tenant unless you say otherwise") so "sounds fine" is a valid fast answer.
- **Never ask what is already answered** by the idea, the repo, `AGENTS.md`, or an earlier message. Asking the user something their README states wastes the turn and signals you did not read.
- **Never ask the user to write the requirements.** "Tell me what you want in the spec" is a failure of this skill. Ask closed questions about decisions; synthesise the text yourself.
- **Record non-answers.** A question the user declines to answer goes to §17 Open Questions together with its recommended default and what changes if the answer differs.
- **Ask once per decision.** Re-asking in a later step because the answer was inconvenient is how confidence in the spec dies.

## 4. Reading an existing codebase

When the idea lands on a repo that already exists:

1. Read `AGENTS.md`, then `README`, then the entry points and configuration. `docs/plan/CONTEXT.md` from a prior run, if present, is a shortcut to the project's durable facts.
2. Map what already exists to the idea: what to build on, what to extend, what the idea would break.
3. Detect the constraints the repo imposes — stack, conventions, migration history, existing tests, deploy pipeline. These become §16 Constraints, and they outrank the idea's imagined stack.
4. Hunt for the parts of the idea already implemented, and for features present in code but absent from the idea — the second is often a requirement the user forgot to mention.
5. Questions that remain are about intent, never about facts the code already settles. "The repo uses Postgres; will the new feature share that database?" — the second half is a real question; the first half is not.
