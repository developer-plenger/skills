# Sourcing — how /design fetches from the internet

`/developer-plenger:design` builds `design.md` from real, current design guidance
rather than inventing it. This reference is the method: what to search for, how
to choose sources, how to adapt them, and what to do when the fetch finds
nothing usable.

Read it before step 5 of `SKILL.md`.

## Start from the app, not from a favorite system

The search is keyed to two things already in the repo, so read them first:

- **The stack**, from `context.md` → `Technology`. A `Next.js + Tailwind` app and
  a `Flutter` app want different starting systems. Name the stack in `## Sources`
  so the choice is auditable.
- **The domain and audience**, from the plan `spec.md` → §5 Target Users, §2
  Problem Statement. A clinical tool and a consumer game have different
  accessibility floors, density, and tone.

## Match a candidate to the stack

Offer the user **2–3 candidates** and let them pick; do not silently choose. A
candidate is a *starting system*, adapted afterward — not a finished answer.
Typical matches (search for the current version, do not assume):

| Stack signal | Strong candidates to search |
|---|---|
| React / Next / Vue + Tailwind | shadcn/ui, Radix Themes, Tailwind UI conventions |
| Plain CSS / design-token tooling | Open Props, Design Tokens Community Group format |
| Flutter / Material | Material 3 (`m3.material.io`) |
| iOS / Apple platforms | Apple Human Interface Guidelines |
| Android native | Material 3 |
| any web app, accessibility-first | W3C WCAG 2.2, ARIA Authoring Practices |

When the user names a system, use it. When they have no preference, recommend
the one that matches the stack and say why in one line.

## How to fetch

Use `WebSearch` to find the current source, then `WebFetch` on the primary page
— the system's own documentation, the framework's docs, or the standards body.
Prefer primary and authoritative sources over aggregator blogs, which go stale.
Fetch the specifics you actually need: the token names and values if the system
publishes them, the type scale, the spacing scale, the component list, and the
accessibility targets.

Record, for `## Sources`, each source's **URL** and a phrase on **what was
adapted** — e.g. `Material 3 (m3.material.io) — color roles and elevation
model; type scale re-cut to our 3 sizes`.

## Adapt, do not paste

- **Adapt every fetched system to this app.** A copied palette that ignores the
  domain reads as generic. Reshape it: pick the roles the app actually has, cut
  the scale to the components in the spec, drop what the app does not use.
- **Attribute.** A system's tokens may be licensed (some are MIT, some are not).
  Never reproduce a palette verbatim without naming its source and license in
  `## Sources`. When in doubt, derive an equivalent from the source's principles
  and say so.
- **State derivations.** A value invented to fill a gap — a focus-ring width, a
  duration — is marked as derived rather than attributed to the source.

## The public-source limit

`WebFetch` **cannot reach authenticated or private sources**: a private Figma
file, an internal Confluence page, a design tool behind a login. When the user
points at such a source, say so plainly and fall back to the public sources
above, or ask them to paste the relevant tokens. Never pretend to have fetched
something you could not reach, and never leave a `## Sources` entry whose URL you
did not actually open.

## When nothing usable is found

If the search returns nothing applicable, do not stall and do not invent a
system in silence. Synthesize a **minimal, accessible** system from first
principles — a neutral palette meeting WCAG AA, a 4-step type scale, a 4-point
spacing scale, the components named in the spec — and say so in `## Sources`:
`Derived from WCAG 2.2 AA contrast requirements; no upstream system adopted`.
A stated derivation is honest; an unstated one is a guess wearing a system's
clothes.

## Ask once, then proceed

Sourcing is the one step that talks to the user mid-run (the candidate choice,
and the UI question when it is ambiguous). Keep it to a single round: present the
candidates with a recommendation, take the answer, and proceed. Do not re-ask
what the repo, an earlier `design.md`, or the user's own words already answer.
