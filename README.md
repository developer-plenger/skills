# developer-plenger/skills

An end-to-end, spec-driven development workflow shipped as one Claude Code plugin. Seven skills carry a project from a sentence-long idea to code that is implemented, reviewed, and tested: `init` registers the skill pack in the repository, `plan` turns the idea into a specification, `slice` cuts the spec into vertical-slice phases, `exec` writes the code, `review` audits it against the spec, `check` proves it with tests, and `fix` repairs what review and check surface. Every hand-off is a file in the repository — `AGENTS.md`, `docs/plan/SPEC.md`, `docs/phases/phase-01-<slug>.md` and the rest — so progress survives the session and is visible in a diff. Depth lives in [docs/workflow.md](docs/workflow.md), [docs/architecture.md](docs/architecture.md), and [docs/state-machine.md](docs/state-machine.md).

## Flow

```text
  INIT -> PLAN -> SLICE -> EXEC -> (REVIEW || CHECK) -> FIX -> (REVIEW || CHECK)
 AGENTS   SPEC   PHASES    CODE      findings            code     both again
          CONTEXT  +tasks
```

REVIEW and CHECK are parallel siblings. `exec -> review` and `exec -> check`, never `exec -> review -> check`. CHECK runs per finished slice or phase by default, not after every single task.

## Skills

| Skill | Invocation | Input | Output | Flips |
| --- | --- | --- | --- | --- |
| init | `/developer-plenger:init` | any existing `AGENTS.md` | `AGENTS.md` | — |
| plan | `/developer-plenger:plan` | your idea in prose | `docs/plan/SPEC.md`, `docs/plan/CONTEXT.md` | — |
| slice | `/developer-plenger:slice` | `docs/plan/SPEC.md` | `docs/phases/phase-NN-<slug>.md` | — |
| exec | `/developer-plenger:exec phase-01` or `/developer-plenger:exec TASK-001` | the phase file, spec, context, source | application source code | `Implemented` |
| review | `/developer-plenger:review phase-01` or `/developer-plenger:review TASK-001` | task, spec, acceptance criteria, code | `docs/reviews/TASK-NNN.md` | `Reviewed` |
| check | `/developer-plenger:check phase-01` or `/developer-plenger:check TASK-001` | acceptance criteria, code | `docs/checks/TASK-NNN.md` | `Tested` |
| fix | `/developer-plenger:fix` | a review or check document | repaired source code, `docs/fixes/TASK-NNN.md` | resets invalidated boxes |

`/developer-plenger:init` asks the user nothing: `AGENTS.md` describes the pack, not the project, so it is identical in every repository. Project facts — the stack, the conventions, the purpose — are written into `docs/plan/CONTEXT.md` by `/developer-plenger:plan`.

`/developer-plenger:fix` never checks a box. It resets boxes to `- [ ]` when its change invalidates their evidence.

## Artifacts

| Artifact | Written by | Location |
| --- | --- | --- |
| Pack registration | `/developer-plenger:init` | `AGENTS.md` |
| Specification | `/developer-plenger:plan` | `docs/plan/SPEC.md` |
| Project context | `/developer-plenger:plan`, plus every skill for the `Current Phase` cursor | `docs/plan/CONTEXT.md` |
| Phase plan | `/developer-plenger:slice` | `docs/phases/phase-NN-<slug>.md` |
| Review | `/developer-plenger:review` | `docs/reviews/TASK-NNN.md` |
| Check | `/developer-plenger:check` | `docs/checks/TASK-NNN.md` |
| Fix | `/developer-plenger:fix` | `docs/fixes/TASK-NNN.md` |

Task IDs are global and unique across phases: `TASK-001`, `TASK-002`, and so on, zero-padded to three digits. Phase IDs come from the filename: `phase-01`, `phase-02`. Findings are numbered inside their own review document — `FINDING-001` in `docs/reviews/TASK-003.md` — and referenced elsewhere as `TASK-003#FINDING-001`.

## Task state

- Three checkboxes in the phase file are the only state carrier: `Implemented` (by `/developer-plenger:exec`, only when the code runs), `Reviewed` (by `/developer-plenger:review`, only when no unresolved finding of Medium severity or higher remains), `Tested` (by `/developer-plenger:check`, only when every acceptance criterion has passing evidence).
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

1. `/developer-plenger:init` — register the pack; the agent writes `AGENTS.md` and asks nothing.
2. `/developer-plenger:plan` — describe the idea; the agent asks its questions, records the stack and the project's conventions, and writes `docs/plan/SPEC.md` and `docs/plan/CONTEXT.md`.
3. `/developer-plenger:slice` — cut the spec into `docs/phases/phase-01-<slug>.md` with tasks and acceptance criteria.
4. `/developer-plenger:exec phase-01` — implement the tasks, dependencies first; `Implemented` flips as the code runs.
5. `/developer-plenger:review phase-01` and `/developer-plenger:check phase-01` — run both, in either order; then `/developer-plenger:fix` on what they surface.

Repeat step 5 until every box in the phase is checked, then `/developer-plenger:slice` produces the next phase. The hand-offs are spelled out in [docs/workflow.md](docs/workflow.md).

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
│   ├── PHASE.md
│   ├── REVIEW.md
│   ├── CHECK.md
│   └── FIX.md
├── docs/
│   ├── workflow.md
│   ├── architecture.md
│   ├── state-machine.md
│   └── design-brief.md
└── README.md
```

## templates/ versus references/

`templates/` holds seven copy-paste seeds — `AGENTS.md`, `SPEC.md`, `CONTEXT.md`, `PHASE.md`, `REVIEW.md`, `CHECK.md`, and `FIX.md` — one per artifact the pack produces. They mirror the skeletons also described in the skills' `references/`. The references are normative: they are what the agent loads at runtime. `templates/` exists so a human can see the shape of `SPEC.md`, a phase file, or `docs/fixes/TASK-NNN.md` without running anything. Six of the seven are skeletons with placeholders; `AGENTS.md` is the exception — its content is fixed pack contract with nothing to fill in. If the two ever diverge, the `references/` files win. See [docs/architecture.md](docs/architecture.md).

## License

MIT. Contributions are welcome as issues and pull requests against this repository; keep the contract in [docs/architecture.md](docs/architecture.md) intact when changing a skill's output shape.
