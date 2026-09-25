# Tracer bullets

## What it is

The tracer bullet is the first slice: the least functionality that still
travels the complete path — user input, through every layer, to a visible
result. Not a prototype and not a demo. It is production code on the real path,
built thin.

A working tracer bullet is usually something like "submit one hard-coded value
from the UI, have it reach the handler, and render the response". It ships.

## Why it goes first

Ordering it first surfaces integration risk while it is cheap. Every unknown you
have — the auth provider's callback shape, whether the build toolchain runs in
CI, whether the ORM maps the type you chose — gets discovered in phase 01 with
one day of sunk cost, instead of in phase 04 after three phases assumed it was
fine.

A tracer bullet also calibrates the plan itself: once the path exists, the
remaining slices are elaborations of something you have felt working, so their
sizes are estimates instead of guesses.

## How to pick it

Walk the user journeys and pick the one that satisfies all four:

1. **Real end to end** — it goes through the actual stack, including deploy or
   build, not a local-only shortcut.
2. **One thin capability** — one action, one result. No variants, no edge
   cases, no configuration UI.
3. **Exercise it today** — after it lands you can run a command or click
   something and observe the result, with no further slices.
4. **Cheapest integration exposure** — among candidates, prefer the one touching
   the most unknowns per line of code: the external service, the unfamiliar
   framework, the build pipeline.

If two candidates tie, take the one a user can see. If none qualifies, the
smallest riskiest integration *is* the tracer bullet — prove the connection
before building features on top of it.

## When it reveals the spec was wrong

The tracer bullet is the cheapest place to be wrong, so expect it. It can return
three kinds of news:

- **The plan was wrong** — the slice depends on something not in the spec.
- **The spec conflicts** — two requirements cannot both hold as written.
- **The spec is silent** — the path needs a decision the spec never made.

All three are spec problems, not implementation problems. **Return to `/plan`
rather than absorbing the change silently.** Absorbing it looks fast and is how
the spec stops describing the product: the next slice slices the old spec, the
code drifts, and `docs/plan/SPEC.md` becomes a document nobody reads while
reviews check code against requirements that no longer exist.

In practice:

1. Stop the slice; keep whatever code still matches the spec.
2. Report the finding with the evidence — the failing assumption, the actual
   behaviour, the file or command that showed it.
3. Run `/plan` to update §17 Open Questions and §18 Decisions, then re-run
   `/slice`. Small, purely local decisions may be recorded in the phase file's
   `## Objective` if the user prefers not to re-plan; say which you did and why.

The rule generalises: any slice may discover a wrong spec. The tracer bullet
just discovers it first, which is the whole point.
