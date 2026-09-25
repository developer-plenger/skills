# Testing — Detection and Method

How to find out how this project tests, and what to run once you know. Never
assume a framework: read the project's own declaration and obey it.

The project's declared command wins over the tool you would have picked — a
script, a Makefile target or a CI step is the project stating its own interface,
and substituting your preferred runner checks something the project does not.
**Say which file you read to decide**, in the check record's Environment block:
"the `test` script in the manifest" is a decision someone can audit; "ran the
tests" is not.

## Detection matrix

Look for these, in the order given. The first hit usually decides the ecosystem;
check the second column for the file that actually declares the command, because
a manifest that merely lists a dependency is weaker evidence than a script or a
task that names the command.

| What to open | What it tells you |
|---|---|
| `package.json` → `scripts` | The declared command: `test`, `test:unit`, `vitest run`, `jest`, `node --test`. **This script wins over anything you would have picked.** |
| `package.json` → `devDependencies` | Which runner is installed when no script names one: `vitest`, `jest`, `mocha`, or the runner in `@types` / `ts-node` / `@swc` pairs. Node's built-in runner shows as `node:test` in `.test.js` files and no dependency at all. |
| `go.mod` | Go. `go test ./...`, scoped with a package path. |
| `pyproject.toml` (`[tool.pytest.ini_options]`), `pytest.ini`, `tox.ini`, `setup.cfg` (`[tool:pytest]`), `conftest.py` | pytest. `pyproject.toml` may also carry a `[tool.uv]`/`[tool.poetry]` test script, or a `noxfile.py` session. |
| `Cargo.toml` | Rust. `cargo test`, scoped with `-p <crate>` or `--test <name>`. |
| `pom.xml` | Maven. `mvn test`, scoped with `-Dtest=Class#method`. |
| `build.gradle` / `build.gradle.kts` | Gradle. `./gradlew test --tests "com.example.FooTest"`. |
| `mix.exs` | Elixir. `mix test`, scoped with a file path or `--only`. |
| `*.csproj` / `*.sln` | .NET. `dotnet test`, scoped with `--filter`. |
| `Makefile` | Targets named `test`, `check`, `test-unit`, `test-integration`. A Makefile target is the project's declared interface when it exists. |
| CI workflow files (`.github/workflows/*.yml`, `.gitlab-ci.yml`, `.circleci/config.yml`) | The command CI actually gates on. When the local project is ambiguous, this is the tiebreaker — it is by definition the command the project treats as its check. |
| `README` / `CONTRIBUTING` | The human-facing instruction. Also a tiebreaker, but read it after the files above; docs drift. |

When two sources disagree — a `Makefile` target running one runner while
`package.json` declares another — prefer the one CI runs, and say so in the
check record's Environment block.

## Which command to run

1. **Narrowest first.** The scoped command for the file or package the task
   touches: the test file, the package path, the test class filter. Read the
   output; a scoped failure localises the problem without waiting on the suite.
2. **Then broader**, only after the scoped run passed and the suite is cheap
   enough to be worth the wait. The broader run is for detecting what your
   change broke elsewhere, not for proving the task's criteria.

A fully green suite that never touched this task's code is not evidence for
this task. Say which command produced which piece of evidence.

## Verify by running, or write a test

Decide per criterion:

- **A criterion observable by exercising the feature** — an HTTP route, a CLI
  command, a rendered page, a script's output — needs the exercise, not a new
  test. Run the app, hit the path, capture the real output. A mocked test that
  asserts your own stub is weaker evidence than one real request.
- **A criterion about a branch, a boundary, or an error path** that the happy
  path cannot reach — an off-by-one, a rejected input, a timeout, an empty
  collection — needs a test. Exercising by hand cannot reliably produce those
  states, and the next person cannot re-run your keystrokes.

When you write a test:

- Put it **next to the existing tests**, in the file layout and naming the repo
  already uses (`__tests__/foo.test.ts`, `foo_test.go`, `tests/test_foo.py`).
- Use the **repo's existing framework, helpers and fixtures**. A new runner, a
  new assertion library or a new fixture directory is a second harness and a
  finding, not a contribution.
- Follow the style of the neighbouring tests: the same setup/teardown shape,
  the same assertion vocabulary, the same test-name convention.
- Make it deterministic and isolated: no reliance on wall-clock time, network,
  execution order, or shared mutable state. Full-suite-safe, not
  passes-alone-safe.
- Keep it minimal: the assertion that fails if this criterion breaks. Not a
  framework, not a suite.

## When the project has no test setup at all

Do not install anything on your own initiative. Instead:

1. Say so, plainly, in the check record's Environment block: which files you
   looked for and did not find.
2. Prove the criteria by **running the thing**: start the app, call the route,
   run the CLI, read the output. Record the command and the observed result.
3. Recommend the **smallest setup the project's stack implies** — the built-in
   runner for the language when there is one (`node --test`, `go test`,
   `python -m unittest`), otherwise the runner the ecosystem overwhelmingly
   uses — and say that adopting it is the user's call.

"I could not prove this with tests" is an acceptable outcome. "There are no
tests, so the check passed" is not.

## Recording evidence

Evidence is the command output or the observation itself, not a claim about it:

```text
$ npx vitest run src/auth
 ✓ src/auth/login.test.ts (4 tests) 112ms
 ✓ src/auth/session.test.ts (3 tests) 41ms
 Test Files  2 passed (2)      Tests  7 passed (7)
```

Record the command, the exit code, and the lines that decide the verdict. A row
that says "tests pass" is a restatement of belief, not evidence, and the next
reader cannot tell whether anything was run.
