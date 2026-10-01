# Design System

<!-- App-wide. One file for the whole app, at the repo root beside AGENTS.md and
     context.md — never per-plan. Read by every /exec run that touches UI.
     Rewrite the affected section in place; never append, never a changelog.
     A UI app fills all ten sections; a project with no UI writes Applicability
     = not applicable and the rest as None. See
     skills/design/references/design-format.md for the contract. -->

## Applicability

{{UI or not applicable — with the evidence: the context.md Technology value and
the spec section that proved it. A UI app states its target platforms here.}}

## Sources

- {{Design system or reference fetched — URL — what was adapted from it.}}
- {{Derived values are named as derived, not attributed to a source.}}

## Colors / Tokens

{{Named semantic tokens with values: background, surface, text, primary, danger…
— plus the light/dark mapping and the contrast ratio of text on its background.}}

## Typography

{{Families, the type scale (sizes and line-heights), weights, and where each is used.}}

## Spacing & Radius

{{The spacing scale, the radius scale, and any grid or breakpoint rules.}}

## Components

{{One line per component — name, variants, the states it supports. Extended in
place by later plans; never a second Components block.}}

## States

{{The cross-cutting states every interactive element defines: hover, focus,
active, disabled, loading, empty, error.}}

## Accessibility

{{Contrast targets met, the focus-ring rule, keyboard reachability, minimum
target size, reduced-motion handling, semantics.}}

## Motion

{{Durations and easings, and which transitions use them. None if the app does
not animate.}}

## Do / Don't

{{Anti-patterns specific to this app — what the system forbids that a developer
would otherwise do.}}
