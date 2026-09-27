# developer-plenger/skills

An end-to-end, spec-driven development workflow shipped as one Claude Code plugin. Seven skills carry a project from a sentence-long idea to code that is implemented, reviewed, and tested: `init` registers the skill pack and creates the empty repository index, `plan` writes one plan's specification, `slice` cuts that spec into development stages, `exec` writes the code, `review` audits it against the spec, `check` proves it with tests, and `fix` repairs what review and check surface. Every hand-off is a file in the repository — `AGENTS.md`, `context.md`, `specs/02-monthly-budgets/spec.md`, `specs/02-monthly-budgets/slice/01-p0/tasks.md` and the rest — so progress survives the session and is visible in a diff.

**Every `/plan` run gets its own folder.** `specs/01-<plan-slug>/` is the initial build, `specs/02-<plan-slug>/` the next feature, `specs/03-<plan-slug>/` the one after. Each folder is self-contained: its own `spec.md` stating what that plan builds, its own `slice/` folder holding its development stages starting at `p0`, its own `TASK-001`, and its own reviews, checks and fixes. A later `/plan` never edits an earlier plan's spec — plans are history, and a correction is the next plan rather than an edit to the last one.

What spans them is `context.md` at the root. Its `Current Development Status` carries one line per plan with three parts — the plan's identity, its stage states, and a one-clause summary of what that plan's `spec.md` builds:

```markdown
- plan-01 — initial build — p0–p2 ✓ — expense entry, monthly total, correcting a past entry
- plan-02 — monthly budgets — p0 ✓ | p1 in progress — a budget per category, and spending shown against it
- plan-03 — CSV export — not sliced yet — expenses and a monthly summary exported as CSV

24 tasks total, 11 done.
```

That is why a fresh agent in any harness reads one file and knows both **what the project does** and **where it stands** — plan 01 was the initial build, plan 02 added budgets, plan 03 is queued — without opening a single spec. `/plan` writes each line's summary clause; `/slice` and the four later skills keep only the state slots current. Depth lives in [docs/workflow.md](docs/workflow.md), [docs/architecture.md](docs/architecture.md), and [docs/state-machine.md](docs/state-machine.md).

## Flow

```text
  INIT     -> PLAN         -> SLICE        -> EXEC -> (REVIEW || CHECK) -> FIX -> (REVIEW || CHECK)
 AGENTS.md   creates         fills that      CODE      findings            code     both again
 context.md  specs/NN-slug/  plan's
             spec.md         slice/NN-pK/
             (a later feature re-enters PLAN and creates the NEXT folder —
              it never edits the one that already exists)

 specs/
   01-initial-build/     spec.md · slice/01-p0…03-p2 · reviews/ checks/ fixes/
   02-monthly-budgets/   spec.md · slice/01-p0…03-p2 · reviews/ checks/ fixes/   ← its own p0, its own TASK-001
   03-csv-export/        spec.md · slice/01-p0…02-p1 · reviews/ checks/ fixes/
```

REVIEW and CHECK are parallel siblings. `exec -> review` and `exec -> check`, never `exec -> review -> check`. CHECK runs per finished stage by default, not after every single task.

## Skills

| Skill | Invocation | Input | Output | Flips |
| --- | --- | --- | --- | --- |
| init | `/developer-plenger:init` | any existing `AGENTS.md`, `context.md` | `AGENTS.md`, an empty `context.md` | — |
| plan | `/developer-plenger:plan <idea>` | your idea in prose, `context.md`, every existing plan's `spec.md`, and the code | `specs/NN-<plan-slug>/spec.md` — a **new** plan folder — and the project's sections in `context.md` | — |
| slice | `/developer-plenger:slice NN-<plan-slug>` | `specs/NN-<plan-slug>/spec.md`, `context.md` | that plan's `slice/NN-pK/tasks.md`, starting at `01-p0` | — |
| exec | `/developer-plenger:exec NN-<plan-slug>/NN-pK` | the slice file, that plan's `spec.md`, `context.md`, source | application source code | `Implemented` |
| review | `/developer-plenger:review NN-<plan-slug>/NN-pK` | task, that plan's spec, acceptance criteria, code | `specs/NN-<plan-slug>/reviews/TASK-NNN.md` | `Reviewed` |
| check | `/developer-plenger:check NN-<plan-slug>/NN-pK` | acceptance criteria, code | `specs/NN-<plan-slug>/checks/TASK-NNN.md` | `Tested` |
| fix | `/developer-plenger:fix NN-<plan-slug>/TASK-001#FINDING-002` | a review or check document | repaired source code, `specs/NN-<plan-slug>/fixes/TASK-NNN.md` | resets invalidated boxes |

`/developer-plenger:init` asks the user nothing: `AGENTS.md` describes the pack, not the project, so it is identical in every repository, and the `context.md` it creates is empty because nothing has been planned yet. Project facts — the stack, the conventions, the purpose — and each plan's spec are written by `/developer-plenger:plan`. Running `/developer-plenger:plan` again creates the next plan folder; it never touches the plans that exist.

Task and stage IDs restart inside each plan folder, so every invocation that names a task carries the plan. That is the one cost of the structure, and it buys a plan that reads and works entirely on its own.

`/developer-plenger:fix` never checks a box. It resets boxes to `- [ ]` when its change invalidates their evidence.

## Artifacts

| Artifact | Written by | Location |
| --- | --- | --- |
| Pack registration | `/developer-plenger:init` | `AGENTS.md` |
| Project context | `/developer-plenger:init` creates it empty; `/developer-plenger:plan` fills its sections and adds a status line per plan; the five later skills keep that status section current and move the cursor | `context.md` |
| Specification | `/developer-plenger:plan` | `specs/NN-<plan-slug>/spec.md` |
| Stage plan | `/developer-plenger:slice` | `specs/NN-<plan-slug>/slice/NN-pK/tasks.md` |
| Review | `/developer-plenger:review` | `specs/NN-<plan-slug>/reviews/TASK-NNN.md` |
| Check | `/developer-plenger:check` | `specs/NN-<plan-slug>/checks/TASK-NNN.md` |
| Fix | `/developer-plenger:fix` | `specs/NN-<plan-slug>/fixes/TASK-NNN.md` |

Task IDs are `TASK-NNN`, zero-padded to three digits, **restarting at `TASK-001` inside every plan folder** — as do `FR-NNN` requirement IDs and `US-NNN` story IDs, because a plan's `spec.md` states only that plan's delta and the plan folder is the namespace. Stage IDs come from the folder name: `01-p0` is `specs/02-monthly-budgets/slice/01-p0/`. Findings are numbered inside their own review document — `FINDING-001` in `specs/02-monthly-budgets/reviews/TASK-003.md` — and referenced as `plan-02/TASK-003#FINDING-001` when the plan is not obvious.

The consequence to plan around: a bare `TASK-001` exists once per plan that has been sliced, so it never identifies a task on its own. Name the plan.

## Task state

- Three checkboxes in the slice file are the only state carrier: `Implemented` (by `/developer-plenger:exec`, only when the code runs), `Reviewed` (by `/developer-plenger:review`, only when no unresolved finding of Medium severity or higher remains), `Tested` (by `/developer-plenger:check`, only when every acceptance criterion has passing evidence).
- There is never a `status:` field. `DONE` is derived when all three are checked, never stored.
- `/developer-plenger:fix` resets exactly the boxes whose evidence its change invalidated: a code change always resets Reviewed and Tested; if the fix shows the task was never really implemented, Implemented too. Reset means `- [ ]`.

Full model, including the parallel middle states: [docs/state-machine.md](docs/state-machine.md).

## Install

The Claude Code flow:

```bash
# add this repository as a marketplace
/plugin marketplace add developer-plenger/skills

# install the plugin from that marketplace
/plugin install developer-plenger
```

Then run `/plugin` to confirm the plugin is listed and enabled. The seven skills become available as `/developer-plenger:init`, `/developer-plenger:plan`, `/developer-plenger:slice`, `/developer-plenger:exec`, `/developer-plenger:review`, `/developer-plenger:check`, and `/developer-plenger:fix`. Plugin skills are namespaced by the plugin name; the bare names `/init`, `/plan`, and `/review` are claimed by Claude Code's own built-ins, so the namespaced form is required for those and is safe for all seven.

## Use it on a project

1. `/developer-plenger:init` — register the pack; the agent writes `AGENTS.md` and an empty `context.md`, and asks nothing.
2. `/developer-plenger:plan` — describe the idea; the agent asks its questions, records the stack and the repository's conventions, and creates `specs/01-initial-build/spec.md`, adding the project's sections and this plan's ledger line to `context.md`.
3. `/developer-plenger:slice 01-initial-build` — cut the spec into `specs/01-initial-build/slice/01-p0/tasks.md` and the following stages, with tasks and acceptance criteria.
4. `/developer-plenger:exec 01-initial-build/01-p0` — implement the tasks, dependencies first; `Implemented` flips as the code runs.
5. `/developer-plenger:review 01-initial-build/01-p0` and `/developer-plenger:check 01-initial-build/01-p0` — run both, in either order; then `/developer-plenger:fix` on what they surface.

Repeat step 5 until every box in the stage is checked, then move to the next stage number.

**When the app gains a feature**, go back to step 2 and run `/developer-plenger:plan` again. The agent creates `specs/02-<plan-slug>/` — a new spec stating only what this feature adds, what already existed and was reused, and the decisions it took — and adds a second ledger line to `context.md`. Then `/developer-plenger:slice 02-<plan-slug>` gives it its own `01-p0` and its own `TASK-001`, and work proceeds exactly as before. The first plan folder is untouched throughout. The hand-offs are spelled out in [docs/workflow.md](docs/workflow.md).

## Agent Runner Descriptors

Each skill ships `skills/<name>/agents/openai.yaml` for OpenAI-compatible agent runners:

```yaml
name: <skill dir name>
description: <one line, human-facing>
instructions: ../SKILL.md
model: gpt-5
tools: [shell, read_file, write_file, apply_patch, search]
```

`model` is a placeholder hint, not a pin. Set it to whatever model the runner should default to; the pack never depends on it.

## Layout

```text
developer-plenger/skills/
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── skills/
│   ├── init/
│   │   ├── SKILL.md
│   │   ├── agents/openai.yaml
│   │   └── references/agents-template.md
│   ├── plan/
│   │   ├── SKILL.md
│   │   ├── agents/openai.yaml
│   │   └── references/
│   │       ├── discovery.md
│   │       ├── evaluation.md
│   │       ├── specification.md
│   │       └── context.md
│   ├── slice/
│   │   ├── SKILL.md
│   │   ├── agents/openai.yaml
│   │   └── references/
│   │       ├── vertical-slice.md
│   │       ├── tracer-bullet.md
│   │       ├── dependency.md
│   │       └── task-state.md
│   ├── exec/
│   │   ├── SKILL.md
│   │   ├── agents/openai.yaml
│   │   └── references/
│   │       ├── implementation.md
│   │       ├── completion.md
│   │       └── task-state.md
│   ├── review/
│   │   ├── SKILL.md
│   │   ├── agents/openai.yaml
│   │   └── references/
│   │       ├── review-checklist.md
│   │       ├── findings.md
│   │       └── task-state.md
│   ├── check/
│   │   ├── SKILL.md
│   │   ├── agents/openai.yaml
│   │   └── references/
│   │       ├── testing.md
│   │       ├── result.md
│   │       └── task-state.md
│   └── fix/
│       ├── SKILL.md
│       ├── agents/openai.yaml
│       └── references/
│           ├── remediation.md
│           └── task-state.md
├── templates/
│   ├── AGENTS.md
│   ├── SPEC.md
│   ├── CONTEXT.md
│   ├── TASKS.md
│   ├── REVIEW.md
│   ├── CHECK.md
│   └── FIX.md
├── docs/
│   ├── workflow.md
│   ├── architecture.md
│   ├── state-machine.md
│   └── design-brief.md
├── scripts/
│   ├── check.sh
│   └── lib/
│       ├── agents_template_sync.py
│       └── reference_links.py
└── README.md
```

## templates/ versus references/

`templates/` holds seven copy-paste seeds — `AGENTS.md`, `SPEC.md`, `CONTEXT.md`, `TASKS.md`, `REVIEW.md`, `CHECK.md`, and `FIX.md` — one per artifact the pack produces. They mirror the skeletons also described in the skills' `references/`. The references are normative: they are what the agent loads at runtime. `templates/` exists so a human can see the shape of a plan's `spec.md`, a stage's `tasks.md`, or `specs/NN-<plan-slug>/fixes/TASK-NNN.md` without running anything. Six of the seven are skeletons with placeholders; `AGENTS.md` is the exception — its content is fixed pack contract with nothing to fill in, which is also why `scripts/check.sh` compares it byte-for-byte against the reference. If the two ever diverge elsewhere, the `references/` files win. See [docs/architecture.md](docs/architecture.md).

## Development

There is no linter or formatter configured in this repository; the one check is

```bash
./scripts/check.sh
```

It needs only `git`, `grep` and `python3`, and it fails on the five ways this pack breaks silently:

1. a manifest that no longer parses;
2. `templates/AGENTS.md` drifting from the canonical text in `skills/init/references/agents-template.md` (the two exist for different readers, so the obvious way to update one is to forget the other);
3. a retired path — `docs/plan/`, `docs/phases/`, `phase-NN-<slug>` — reappearing in a skill, a template, a manifest or `docs/` (the README is exempt: this section names them on purpose);
4. a `SKILL.md` linking a `references/*.md` that does not exist;
5. an artifact shape changing size: `context.md` losing a section, `spec.md` losing a section, a skill disappearing from the contract, a template vanishing;
6. retired-layout vocabulary reappearing — `<NN-slug>`, `## Apps`, `Current Position`, `plans/plan-NN` — which means the design drifted back to one of the two earlier models: many app folders sharing one spec, or one spec amended in place by every plan.

Run it after any change to a skill, a template or a doc.

## License

MIT. Contributions are welcome as issues and pull requests against this repository; keep the contract in [docs/architecture.md](docs/architecture.md) intact when changing a skill's output shape.
