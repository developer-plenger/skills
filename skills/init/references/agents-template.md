# AGENTS.md — the pack contract

Everything `/developer-plenger:init` needs to write, check and repair `AGENTS.md`.
Read this file before step 2 of `SKILL.md`.

## 1. What AGENTS.md is

`AGENTS.md` registers the skill pack for the agents working in this repository.
It says which skills exist, what each one produces, where each artifact lives, and
how task state works. Its content is **the same in every project** — it is pack
contract, not project description.

It deliberately does **not** describe the project. Purpose, target users,
features, stack, architecture and the project's own conventions are project
facts; they live in `docs/plan/CONTEXT.md`, which `/developer-plenger:plan`
writes. A skill that needs them reads that file. See
`skills/plan/references/context.md`.

Two consequences, and they define this skill:

- **`/init` asks the user nothing.** There is no project-specific content to
  gather, so there is no question worth asking. The whole run is: read, compare,
  write, report.
- **`/init` never inspects the codebase** to infer a stack, a purpose, or an
  architecture. Inferring those is `/plan`'s job, done once there is an idea to
  anchor them to. Detection here would produce exactly the project description
  this file is meant to stop carrying.

## 2. The canonical text

Write this content verbatim. It is the whole file. Because it is identical in
every project, conformance is a comparison, not a judgement call — there is no
section to fill in, no placeholder to resolve, no `unknown` to mark.

~~~~markdown
# developer-plenger skill pack

This file registers the `developer-plenger` skill pack for every agent working in
this repository. `/developer-plenger:init` writes and maintains it, and its
content is the same in every project: it describes how the pack's skills work,
never what this project is. Project-specific facts — the stack, the conventions,
the purpose — live in `docs/plan/CONTEXT.md`, written by `/developer-plenger:plan`.

## Workflow

The registered chain is:

```text
INIT → PLAN → SLICE → EXEC → (REVIEW ∥ CHECK) → FIX
```

- REVIEW and CHECK are siblings of EXEC, never a chain: the edges are `exec → review` and `exec → check`, never `exec → review → check`. Either may run first, either may run without the other, and both may run on the same task.
- CHECK runs per finished slice or phase by default, plus whenever a single task needs a test result before anyone can trust it.
- FIX repairs what review and check surfaced, then resets the checkboxes its change invalidated.

Invoke with `/developer-plenger:init`, `/developer-plenger:plan`, `/developer-plenger:slice`, `/developer-plenger:exec TASK-NNN`, `/developer-plenger:review TASK-NNN`, `/developer-plenger:check TASK-NNN`, `/developer-plenger:fix TASK-NNN`. Plugin skills are namespaced by the plugin name; the bare names `/init`, `/plan`, and `/review` are claimed by Claude Code's own built-ins, so the namespaced form is required for those and is safe for all seven.

## Artifacts

Every hand-off is a file in the repository, never chat state. Nothing important lives in the conversation.

| Artifact | Written by | Location |
|---|---|---|
| Operating context | `/developer-plenger:init` | `AGENTS.md` |
| Specification | `/developer-plenger:plan` | `docs/plan/SPEC.md` |
| Project context | `/developer-plenger:plan` | `docs/plan/CONTEXT.md` |
| Phase plan | `/developer-plenger:slice` | `docs/phases/phase-NN-<slug>.md` |
| Review | `/developer-plenger:review` | `docs/reviews/TASK-NNN.md` |
| Check | `/developer-plenger:check` | `docs/checks/TASK-NNN.md` |
| Fix | `/developer-plenger:fix` | `docs/fixes/TASK-NNN.md` |

The skill that writes an artifact also creates its directory: `/plan` creates `docs/plan/`, `/slice` creates `docs/phases/`, `/review` creates `docs/reviews/`, `/check` creates `docs/checks/`, and `/fix` creates `docs/fixes/`.

Task IDs are global and unique across phases: `TASK-001`, `TASK-002`, zero-padded to three digits. Phase IDs come from the filename: `phase-01`, `phase-02`. Findings are numbered inside their own review document — `FINDING-001` in `docs/reviews/TASK-003.md` — and referenced elsewhere as `TASK-003#FINDING-001`.

## Skill Rules

One entry per skill. All seven, in this shape.

### INIT

Prepare the pack's operating context. Writes this file and asks nothing.

- Invocation: `/developer-plenger:init`
- Input: the repository's `AGENTS.md`, if one already exists
- Produces: `AGENTS.md`

### PLAN

Turn a raw idea into a specification, and record the project's stack and conventions.

- Invocation: `/developer-plenger:plan <idea>`
- Input: the user's idea, and the existing codebase when the idea lands on one
- Produces: `docs/plan/SPEC.md`, `docs/plan/CONTEXT.md`

### SLICE

Cut a stable specification into ordered vertical slices and tasks.

- Invocation: `/developer-plenger:slice`
- Input: `docs/plan/SPEC.md`
- Produces: `docs/phases/phase-NN-<slug>.md`, and the global task ID sequence

### EXEC

Implement a task, and check its `Implemented` box only once the code actually runs. Never check a box the code does not earn.

- Invocation: `/developer-plenger:exec TASK-NNN` or `/developer-plenger:exec phase-NN`
- Input: the phase file, `docs/plan/SPEC.md`, `docs/plan/CONTEXT.md`, and the existing source
- Produces: source code; checks `Implemented`

### REVIEW

Review an implementation against its spec and acceptance criteria, recording one numbered finding per problem. Never edits the code it reviews.

- Invocation: `/developer-plenger:review TASK-NNN` or `/developer-plenger:review phase-NN`
- Input: the task, the spec section it came from, its acceptance criteria, and the implementation
- Produces: `docs/reviews/TASK-NNN.md`; checks `Reviewed` when no unresolved finding of Medium or higher remains

### CHECK

Detect the testing ecosystem instead of assuming one, then prove each acceptance criterion. Never checks `Tested` without passing evidence.

- Invocation: `/developer-plenger:check TASK-NNN` or `/developer-plenger:check phase-NN`
- Input: the task's acceptance criteria and the implementation
- Produces: `docs/checks/TASK-NNN.md`; checks `Tested` when every acceptance criterion has passing evidence

### FIX

Repair what review and check surfaced, then reset the boxes that evidence no longer covers. Never checks a box; reset always means `- [ ]`.

- Invocation: `/developer-plenger:fix TASK-NNN#FINDING-NNN` or `/developer-plenger:fix TASK-NNN`
- Input: `docs/reviews/TASK-NNN.md` and/or `docs/checks/TASK-NNN.md`
- Produces: fixes plus `docs/fixes/TASK-NNN.md`; resets the boxes its change invalidated

## Task State

Task state lives in the three checkboxes on the task: `Implemented`, `Reviewed`, `Tested`. There is never a `status:` field. One owner per box:

- `Implemented` is set by `/developer-plenger:exec`.
- `Reviewed` is set by `/developer-plenger:review`, only when no unresolved finding of severity Medium or higher remains.
- `Tested` is set by `/developer-plenger:check`, only when every acceptance criterion has passing evidence.

`DONE` is derived: all three boxes checked. It is never stored. `/developer-plenger:fix` resets the boxes its change invalidated; a code change always resets `Reviewed` and `Tested`.
~~~~

`templates/AGENTS.md` in the pack repository is a copy-paste seed of the same text.
If the two ever diverge, this file wins — re-copy the template from here.

## 3. The conformance check

The sections, in order, and what makes each one conformant:

| Section | Conformant when |
|---|---|
| `# developer-plenger skill pack` | The title, and the paragraph naming the pack, saying the content is project-independent, and pointing at `docs/plan/CONTEXT.md` for project facts. |
| `## Workflow` | The chain, the REVIEW/CHECK sibling rule, the CHECK cadence, the FIX reset rule, and the namespaced invocation sentence — all seven. |
| `## Artifacts` | The seven-row table, the directory-creation sentence, and the ID-convention paragraph. |
| `## Skill Rules` | Exactly one `###` per skill — all seven, no more and no fewer — each with its one-line description, invocation, input and output. |
| `## Task State` | The three named boxes, the no-`status:` rule, one owner per box with its condition, and the derived-`DONE` sentence. |

A file missing a section, carrying a section with drifted content, or naming a
skill count other than seven is non-conformant.

## 4. What to do with an existing AGENTS.md or CLAUDE.md

Never clobber the user's file. The pack's sections are canonical; anything else
in the file is the user's and survives.

1. Read the existing `AGENTS.md` in full.
2. Compare it against §3.
3. If every section conforms, write nothing and say so.
4. If a pack section is missing or drifted, write the canonical version into
   place. Do not reshuffle the user's own sections, and do not delete content
   that is not a pack section — a file that also carries project notes keeps
   them; report what you left in place and where it belongs
   (`docs/plan/CONTEXT.md`, usually).
5. If a later `/plan` run has already written `docs/plan/CONTEXT.md`, that file
   is the home for anything project-shaped that the old `AGENTS.md` held. Point
   the user at it rather than moving content yourself — `/init` does not own
   `CONTEXT.md` beyond its `Current Phase` cursor.

### CLAUDE.md exists

Claude Code reads `CLAUDE.md`; this pack is canonical on `AGENTS.md`. Pick one of
two dispositions and tell the user which and why:

- **Symlink** — recommended when `CLAUDE.md` has no instructions that differ per tool: move any unique content from `CLAUDE.md` into `AGENTS.md`, then replace `CLAUDE.md` with a symlink (`ln -sf AGENTS.md CLAUDE.md`). One source of truth; both tools read the same file; no future drift.
- **Duplicate with a pointer** — when the user wants tool-specific instructions in `CLAUDE.md`, or the filesystem/git setup does not carry symlinks well (e.g. checked out on Windows without symlink support). Keep `CLAUDE.md` as a short file that points at `AGENTS.md` and holds only what applies to Claude Code alone; accept that every future change to shared content must be made in both.

Both `AGENTS.md` and `CLAUDE.md` existing with overlapping content and no pointer
is the failure mode to avoid: the two drift and later skills read different
truths.
