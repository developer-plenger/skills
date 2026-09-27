# Tracer bullets

## What it is

The tracer bullet is a plan's first stage: the least functionality that still
travels the complete path — user input, through every layer, to a visible
result. Not a prototype and not a demo. It is production code on the real path,
built thin.

A working tracer bullet is usually something like "submit one hard-coded value
from the UI, have it reach the handler, and render the response". It ships.

## Why it goes first

Ordering it first surfaces integration risk while it is cheap. Every unknown you
have — the auth provider's callback shape, whether the build toolchain runs in
CI, whether the ORM maps the type you chose — gets discovered in the first stage
with one day of sunk cost, instead of in the fourth stage after three stages
assumed it was fine.

A tracer bullet also calibrates the plan itself: once the path exists, the
remaining stages are elaborations of something you have felt working, so their
sizes are estimates instead of guesses.

## What it means on a later plan

On `plan-01` the tracer bullet is the whole product's thinnest path, because the
product does not exist yet. On a later plan the app already runs, so the tracer
bullet is the thinnest path **this plan's feature** travels — and the integration
risk it exists to surface is different: whether the new feature fits the seams
the earlier plans left, rather than whether the stack works at all.

Two consequences:

- **It is usually thinner than plan-01's.** The layers exist; only the new path
  through them is unknown. A stage that re-proves the framework is wasted.
- **It may not be the plan's first requirement.** If the riskiest unknown is the
  integration with an earlier plan's data, the tracer bullet is the stage that
  touches it, and the cheap stages wait behind it.

A plan with no genuine integration unknown still starts with its thinnest
end-to-end path, because that is what gives the rest of the stages a working
reference to elaborate.

## How to pick it

Walk the user journeys and pick the one that satisfies all four:

1. **Real end to end** — it goes through the actual stack, including deploy or
   build, not a local-only shortcut.
2. **One thin capability** — one action, one result. No variants, no edge
   cases, no configuration UI.
3. **Exercise it today** — after it lands you can run a command or click
   something and observe the result, with no further stages.
4. **Cheapest integration exposure** — among candidates, prefer the one touching
   the most unknowns per line of code: the external service, the unfamiliar
   framework, the build pipeline, or on a later plan the earlier plan's schema
   and contracts.

If two candidates tie, take the one a user can see. If none qualifies, the
smallest riskiest integration *is* the tracer bullet — prove the connection
before building on top of it.

## When it reveals the plan spec was wrong

The tracer bullet is the cheapest place to be wrong, so expect it. It can return
three kinds of news:

- **The plan was wrong** — the stage depends on something not in the spec.
- **The spec conflicts** — two requirements cannot both hold as written.
- **The spec is silent** — the path needs a decision the spec never made.

All three are spec problems, not implementation problems. **Amend the spec rather
than absorbing the change silently.** Absorbing it looks fast and is how the spec
stops describing the product: the next stage is cut from the old spec, the code
drifts, and `specs/NN-<plan-slug>/spec.md` becomes a document nobody reads while
reviews check code against requirements that no longer exist.

In practice:

1. Stop the stage; keep whatever code still matches the spec.
2. Report the finding with the evidence — the failing assumption, the actual
   behaviour, the file or command that showed it.
3. Run `/plan` again. It creates a new plan whose spec corrects this one — an
   earlier plan's spec is a historical record and is never edited to match — and
   that new plan is sliced in turn. Small, purely local decisions may be recorded
   in the stage file's `## Objective` if the user prefers not to re-plan; say
   which you did and why.

Correcting a spec is a new plan, not an edit to the old one. That is what keeps
the plan folders readable as history: `plan-03/spec.md` says what plan 03 thought,
`plan-04/spec.md` says what replaced it, and `context.md`'s `Important Decisions`
carries the current truth.

The rule generalises: any stage may discover a wrong spec. The tracer bullet
just discovers it first, which is the whole point.
