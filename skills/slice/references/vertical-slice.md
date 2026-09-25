# Vertical slices

## What makes a slice vertical

A slice is vertical when it is a thin path through **every layer** the product
needs to deliver one result, and a user could exercise that path end to end
today. Layers here means whatever your stack calls them — UI, HTTP handler,
service, database; or CLI flag, parser, core, file writer. The count varies; the
requirement does not: every layer the feature touches is present in the slice.

The test is behavioural, not structural. Ask: *can I describe this slice as
"a user can now do X and see Y"?* If the honest answer is "the models exist", it
is not a slice.

## Horizontal layer slices and why they fail

A horizontal slice completes one layer for many features:

```
phase-01 — Database schema for all features
phase-02 — All API endpoints
phase-03 — All UI screens
```

This looks efficient and is the most common way to lose a project. Nothing is
demonstrable until the last phase, so nothing is verifiable until then either:
the first time anyone can tell whether the schema was right is after the UI is
built, when changing it costs all three phases. Progress is measured in files
written rather than working behaviour, and every integration surprise lands at
the end, in one heap, with no budget left.

A vertical slice front-loads those surprises into a phase small enough to
absorb them.

## Sizing

**One slice = one reviewable unit ≈ a day of work, with one objective a user can
see.** Concretely:

- One objective, stated as something a user can do — not "refactor auth" but
  "a visitor can register and is logged in afterwards".
- Reviewable in one sitting. If a reviewer needs a map to hold the diff in
  their head, split it.
- Big enough to be worth running. A slice that changes one line per layer
  proves nothing about their integration.

Split or merge against those, not against a fixed task count. When a slice is
still too big after one split, split by journey step, not by layer — "user can
register" and "user can log in" are two slices; "auth tables" and "auth
screens" are one horizontal slice wearing two filenames.

## Mapping SPEC → slices

Every functional requirement (§8) lands in exactly one slice. Exactly one
because a requirement split across slices cannot be declared done by any single
phase, so it silently survives until nobody remembers who owned it.

Record the mapping in the phase's `## Vertical Slice`, naming the requirements
the slice satisfies — requirement IDs, or the requirement's heading when the
spec has no IDs.

```
## Vertical Slice

A visitor can submit the contact form and receives a confirmation email.
Satisfies §8 Contact Form; §7 "As a visitor I want to ask a question".
```

Coverage check before you finish:

- every §8 requirement appears in exactly one slice — none missing, none twice;
- every slice names at least one requirement — a slice satisfying nothing is
  either scope creep or a misplaced layer;
- requirements that depend on §11–§15 (technical, security, data, integration)
  carry those constraints into the slice that needs them rather than becoming
  slices of their own. "Set up the database" is not a user-facing outcome; it is
  a constraint on the first slice that stores something.
