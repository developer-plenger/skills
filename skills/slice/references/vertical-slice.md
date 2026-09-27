# Vertical stages

A **stage** is one step of a plan's execution. The plan's `spec.md` says what to
build and why; `/slice` cuts that spec into stages, each a slice of the plan cut
down to one verifiable result. The word slice and stage name the same thing from
two sides — the plan's step, cut as a vertical slice — and the folder is
`slice/NN-pK/`, so both spellings appear in this pack.

## What makes a stage vertical

A slice is vertical when it is a thin path through **every layer** the product
needs to deliver one result, and a user could exercise that path end to end
today. Layers here means whatever your stack calls them — UI, HTTP handler,
service, database; or CLI flag, parser, core, file writer. The count varies; the
requirement does not: every layer the feature touches is present in the slice.

The test is behavioural, not structural. Ask: *can I describe this stage as
"a user can now do X and see Y"?* If the honest answer is "the models exist", it
is not a stage.

## Horizontal layer stages and why they fail

A horizontal stage completes one layer for many features:

```
01-p0 — Database schema for all features
02-p1 — All API endpoints
03-p2 — All UI screens
```

This looks efficient and is the most common way to lose a project. Nothing is
demonstrable until the last stage, so nothing is verifiable until then either:
the first time anyone can tell whether the schema was right is after the UI is
built, when changing it costs all three stages. Progress is measured in files
written rather than working behaviour, and every integration surprise lands at
the end, in one heap, with no budget left.

A vertical stage front-loads those surprises into a stage small enough to
absorb them.

## Sizing

**One stage = one reviewable unit ≈ a day of work, with one objective a user can
see.** Concretely:

- One objective, stated as something a user can do — not "refactor auth" but
  "a visitor can register and is logged in afterwards".
- Reviewable in one sitting. If a reviewer needs a map to hold the diff in
  their head, split it.
- Big enough to be worth running. A stage that changes one line per layer
  proves nothing about their integration.

Split or merge against those, not against a fixed task count. When a stage is
still too big after one split, split by journey step, not by layer — "user can
register" and "user can log in" are two stages; "auth tables" and "auth
screens" are one horizontal stage wearing two filenames.

## Mapping the plan spec → stages

Every functional requirement (§8) of **the plan's** spec lands in exactly one
stage. Exactly one because a requirement split across stages cannot be declared
done by any single stage, so it silently survives until nobody remembers who
owned it.

A plan spec lists only that plan's delta, so the set to cover is small and
well-defined: the requirements this plan introduced. An earlier plan's
requirements are not re-cut here — they were cut when that plan was sliced, and a
requirement that plan 02 merely *uses* is not plan 02's to sequence.

On a later `/slice` run for the same plan, "every §8 requirement" means every
requirement **that has no stage yet**. Requirements already covered by an existing
stage are not re-cut; that run appends.

Record the mapping in the stage's `## Vertical Slice`, naming the requirements it
satisfies — requirement IDs, or the requirement's heading when the spec has no IDs.

```
## Vertical Slice

A visitor can submit the contact form and receives a confirmation email.
Satisfies §8 Contact Form; §7 "As a visitor I want to ask a question".
```

Coverage check before you finish:

- every §8 requirement of this plan's spec appears in exactly one stage — none missing, none twice;
- every stage names at least one requirement — a stage satisfying nothing is
  either scope creep or a misplaced layer;
- requirements that depend on §11–§15 (technical, security, data, integration)
  carry those constraints into the stage that needs them rather than becoming
  stages of their own. "Set up the database" is not a user-facing outcome; it is
  a constraint on the first stage that stores something.
- a stage whose work is entirely in an earlier plan's territory belongs to that
  plan, not this one — the plan folder is what a stage's requirements are traced
  against.
