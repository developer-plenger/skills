# Definition of implemented, validation, and the report

## Definition of implemented

The changed path **actually runs**. That means: the thing the task changed is
built and started, and the behaviour the criterion describes is exercised —
a request answered, a command printed its output, the screen rendered the value,
the job wrote the row.

"It compiles" is not done. Neither is "the types check", "the tests for the
neighbouring code still pass", or "this function is obviously correct". Those say
the code is *plausibly* correct; the box claims the path runs, and it is checked
only after you watched it run.

If the path genuinely cannot be run — no runtime available, needs credentials the
user holds, needs hardware — do not check the box. Report the limitation and the
exact command to run once the prerequisite exists. An honest unchecked box is
worth more than a checked one nobody can reproduce.

## Validate per project type

Discover the runner; never assume it. Look at what the repo declares, then use it:

- **Node/JS/TS** — `package.json` scripts (`dev`, `start`, `test`); package manager
  from the lockfile (`pnpm-lock.yaml`, `yarn.lock`, `bun.lockb`, else npm).
- **Python** — `pyproject.toml`, `requirements.txt`, `manage.py`, `__main__.py`;
  the venv the repo uses.
- **Go** — `go.mod`; `go build ./... && go run ./cmd/...`.
- **Rust** — `Cargo.toml`; `cargo build`, `cargo run --bin <name>`.
- **JVM** — `pom.xml` or `build.gradle(.kts)`; the wrapper (`./mvnw`, `./gradlew`).
- **Web UI change** — start the dev server and load the page; observe the rendered
  result, not just the HTTP 200.
- **CLI** — invoke the binary with the arguments the criterion names.
- **Library** — the smallest caller that exercises the changed API; a script in a
  temp directory is fine, and you may remove it after (never leave it in the repo).
- **No build system at all** — run the thing the README or `docs/plan/CONTEXT.md` says how to run,
  or the plain interpreter/compiler invocation.

Read `docs/plan/CONTEXT.md` first for the project's own commands — its `Project
Rules` section carries the conventions and the commands to run before finishing,
and a repo that documents `make dev` should not be started with a guess.

Manual smoke is acceptable evidence and often the right one. Record the exact
command and what it printed; do not describe what it "should" do.

## Validating in a multi-task phase

`/exec phase-01` validates each task as it lands, and may run the phase's own
smoke path once at the end to confirm the tasks still compose. It does not run
the project's full test suite to close boxes — that is `/check`'s job, and it owns
the `Tested` box. The exception is the test a criterion cannot be observed
without (see `implementation.md`): that one runs here.

## Checking dependencies

A task with an unchecked `#### Dependencies` entry is **BLOCKED**. The dependency
is not cosmetic — the code it names does not exist yet, so the task cannot be
implemented or validated. `/exec` implements the blocker or a different ready
task, and reports the block rather than working around it.

The same applies at phase level: a phase whose `### BLOCKED BY` names an unlanded
task or phase cannot be started.

## The report

Give this to the user after each task, in this shape:

```
TASK-003 — Login endpoint

Status: Implemented (checked) | BLOCKED (by TASK-001) | Not run

Files touched:
- src/auth/login.ts (new)
- src/auth/routes.ts (route registration)

Ran:
- `pnpm dev` then `curl -X POST localhost:3000/login -d '{"email":"a@b.c"}'
  -p ''`
- printed: 401 {"error":"invalid_credentials"} for the wrong password,
  200 {"token":"..."} for the seeded user

Acceptance criteria met:
- POST /login with valid credentials returns 200 and a session token — observed
- Wrong password returns 401 and creates no session — observed

Left for /check:
- Session expiry after 24h (not observable without time control)

Blockers: none

Next: /review TASK-003 or /check TASK-003
```

Requirements for this report:

- **Files touched** — the complete list; no file changed outside the task's scope
  should appear, and if one did, say why.
- **Ran** — the literal command and its real output, including the failing case
  you tested. Do not summarise "tests pass"; quote what you saw.
- **Acceptance criteria met** — one line per criterion, each marked *observed*
  (you saw it) or left for `/check`. Do not mark a criterion observed because the
  code looks right.
- **Left for /check** — name them; never silently skip a criterion.
- **Blockers** — the specific unchecked dependency, or the prerequisite that
  prevented running the path.
- **Next** — the command that follows.

Report notes (out-of-scope problems found, conventions chosen, deferrable open
questions inherited from the phase) go after the block, kept short. A note is
where an unrequested change goes — the box is checked on the task as specified,
not on the task as improved.
