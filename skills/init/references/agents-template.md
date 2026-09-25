# AGENTS.md contract, detection checklist, merge rule, evidence rule

Everything `/init` needs to produce a project's operating context. Read this file before step 2 of `SKILL.md`.

## 1. AGENTS.md, section by section

Write the sections in this order. One section missing is an incomplete run.

| Section | What belongs in it |
|---|---|
| `# Project Context` | Title only; the file is the project's shared context for every later skill. |
| `## Project` | Name, one-line description, repository layout summary (3–6 top-level directories and what lives in each). |
| `## Purpose` | Why the project exists, in the user's terms — not a feature list. |
| `## Target Users` | Who uses it, one line each. Internal/admin roles count. |
| `## Features` | Bullet list of what the product does. Capabilities, not implementations. |
| `## Architecture` | The shape: monolith/services, boundaries, data stores, external services. Two to six lines; a diagram only if it already exists in the repo. |
| `## Technology` | The detected stack, one line per layer: language, framework, package manager, test runner, build tooling, database, deployment. Each entry names the fact's source file. |
| `## Workflow` | The registered chain: `INIT → PLAN → SLICE → EXEC → (REVIEW ∥ CHECK) → FIX`. State that REVIEW and CHECK are siblings of EXEC, that CHECK runs per finished slice/phase by default (plus whenever a task needs a test to be trusted), and that FIX resets the boxes its change invalidated. |
| `## Skill Rules` | One `### <SKILL NAME>` per skill — all seven — each saying what the skill does in this project, its invocation, its input artifact, and its output artifact. See §2. |
| `## Project Rules` | The project's own conventions: branching, commit style, formatting, commands to run before finishing, anything the user told you that is not already covered. Keep to facts you were given. |
| `## Artifacts` | The seven-artifact table below, verbatim in shape. |
| `## Task State` | The rule from §3. |

Two sections here are different in kind from the rest. `## Skill Rules` and `## Artifacts` are the pack's own contract and are always identical from project to project; everything else is this project's content.

If any project-specific section cannot be filled from evidence, write `unknown` rather than a plausible guess. A later skill can resolve an `unknown`; it cannot recover from a confident error.

## 2. Skill Rules entries

Write one `###` per skill, using this shape:

```markdown
### PLAN

Turn a raw idea into a specification.

- Invocation: `/plan <idea>`
- Input: the user's idea, or an existing codebase plus the idea that lands on it
- Produces: `docs/plan/SPEC.md`, `docs/plan/CONTEXT.md`
```

| Skill | Invocation | Produces |
|---|---|---|
| INIT | `/init` | `AGENTS.md` |
| PLAN | `/plan` | `docs/plan/SPEC.md`, `docs/plan/CONTEXT.md` |
| SLICE | `/slice` | `docs/phases/phase-NN-<slug>.md` |
| EXEC | `/exec TASK-NNN` or `/exec phase-NN` | source code; checks `Implemented` |
| REVIEW | `/review TASK-NNN` or `/review phase-NN` | `docs/reviews/TASK-NNN.md`; checks `Reviewed` when no unresolved finding of Medium or higher remains |
| CHECK | `/check TASK-NNN` or `/check phase-NN` | `docs/checks/TASK-NNN.md`; checks `Tested` when every acceptance criterion has passing evidence |
| FIX | `/fix TASK-NNN#FINDING-NNN` or `/fix TASK-NNN` | fixes plus `docs/fixes/TASK-NNN.md`; resets the boxes its change invalidated |

Task IDs are global and unique across phases (`TASK-001`), zero-padded to three digits. Phase IDs come from the filename (`phase-01`). Findings are numbered inside their review doc (`FINDING-001`) and referenced as `TASK-003#FINDING-001`.

## 3. Artifacts table and Task State rule

```markdown
## Artifacts

| Artifact | Written by | Location |
|---|---|---|
| Operating context | `/init` | `AGENTS.md` |
| Specification | `/plan` | `docs/plan/SPEC.md` |
| Project context | `/plan` | `docs/plan/CONTEXT.md` |
| Phase plan | `/slice` | `docs/phases/phase-NN-<slug>.md` |
| Review | `/review` | `docs/reviews/TASK-NNN.md` |
| Check | `/check` | `docs/checks/TASK-NNN.md` |
| Fix | `/fix` | `docs/fixes/TASK-NNN.md` |
```

```markdown
## Task State

Task state lives in the three checkboxes on the task: `Implemented`, `Reviewed`, `Tested`. There is never a `status:` field. One owner per box:

- `Implemented` is set by `/exec`.
- `Reviewed` is set by `/review`, only when no unresolved finding of severity Medium or higher remains.
- `Tested` is set by `/check`, only when every acceptance criterion has passing evidence.

`DONE` is derived: all three boxes checked. It is never stored. `/fix` resets the boxes its change invalidated; a code change always resets `Reviewed` and `Tested`.
```

## 4. Detection checklist

Look for these files and derive: language(s), framework(s), package manager, test runner, build tooling, database, deployment target, CI, existing docs, git presence.

| Thing to detect | Files that prove it |
|---|---|
| Language | file extensions across the tree; `go.mod`, `Cargo.toml`, `pyproject.toml`, `Gemfile`, `pom.xml`, `build.gradle`, `*.csproj` |
| Framework | dependencies in the manifest: `next`, `react`, `django`, `flask`, `fastapi`, `rails`, `spring`, `laravel` |
| Package manager | lockfiles: `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, `bun.lockb`, `uv.lock`, `poetry.lock`, `Pipfile.lock`, `Gemfile.lock`, `go.sum` |
| Test runner | manifest scripts and dev-dependencies (`vitest`, `jest`, `pytest`, `playwright`, `rspec`); config files (`vitest.config.*`, `jest.config.*`, `pytest.ini`, `tox.ini`, `phpunit.xml`); `*_test.go` files |
| Build tooling | `Makefile`, `justfile`, `Taskfile`, `vite.config.*`, `webpack.config.*`, `tsconfig.json`, `Dockerfile`, `docker-compose.yml`, `.github/workflows/*`, `.gitlab-ci.yml` |
| Database | `prisma/schema.prisma`, `migrations/`, `alembic.ini`, `db/schema.rb`, `.env.example` database URLs |
| Existing docs | `README*`, `docs/**`, `CONTRIBUTING*`, `CHANGELOG*`, ADRs |
| Agent context | `AGENTS.md`, `CLAUDE.md`, `.cursor/rules`, `.github/copilot-instructions.md` |
| Git | `.git/` present; current branch; whether `docs/` is tracked |

Record the proving file next to each detected fact. A detection with no proving file is a guess and does not go in `AGENTS.md`.

Commands worth running, when the tool exists and the repo is small enough: `git log --oneline -10` for commit style, `git status` for work in progress, and the project's own `test`/`build` scripts only if the user asks — never run them as part of detection.

## 5. Merge rule for an existing AGENTS.md or CLAUDE.md

Never clobber. The user's file wins.

1. Read the existing file in full.
2. Identify which pack sections are already present, under any heading names the user chose.
3. Add only the missing sections. Leave existing sections where they are, in the user's order; do not reshuffle a file you did not write.
4. Where an existing section covers the same ground with different wording, keep the user's wording and fold in only the missing facts — `## Skill Rules` and `## Artifacts` are the exception: they are pack contract, so if the file already has its own workflow registration, extend it rather than duplicating the table twice.
5. Never delete content to "tidy" the file.

### AGENTS.md exists

Refresh it in place. Everything already there survives unless the user says otherwise.

### CLAUDE.md exists

Claude Code reads `CLAUDE.md`; this pack is canonical on `AGENTS.md`. Pick one of two dispositions and tell the user which and why:

- **Symlink** — recommended when `CLAUDE.md` has no instructions that differ per tool: move any unique content from `CLAUDE.md` into `AGENTS.md`, then replace `CLAUDE.md` with a symlink (`ln -sf AGENTS.md CLAUDE.md`). One source of truth; both tools read the same file; no future drift.
- **Duplicate with a pointer** — when the user wants tool-specific instructions in `CLAUDE.md`, or the filesystem/git setup does not carry symlinks well (e.g. checked out on Windows without symlink support). Keep `CLAUDE.md` as a short file that points at `AGENTS.md` and holds only what applies to Claude Code alone; accept that every future change to shared content must be made in both.

Both `AGENTS.md` and `CLAUDE.md` existing with overlapping content and no pointer is the failure mode to avoid: the two drift and later skills read different truths.

## 6. Evidence rule

Every line written into `AGENTS.md` traces to one of exactly two sources:

1. a file you read in this session, or
2. an answer the user gave you.

Anything else is written `unknown` — including things that are probably true. `unknown` is a valid, honest state that a later skill resolves; a plausible guess is not, because no later skill knows to revisit it.

When the user answers a question, that answer is evidence and may be quoted as its source.
