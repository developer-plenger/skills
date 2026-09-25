# Check Document

The exact format of `docs/checks/TASK-NNN.md` — the record that proves which
acceptance criteria were verified, how, and with what result.

One file per task: TASK-003 → `docs/checks/TASK-003.md`.

## Format

```markdown
# Check — TASK-003

## Environment

- Framework detected: Vitest 1.6 (devDependency in `package.json`)
- How it was detected: the `test` script in `package.json` runs
  `vitest run`; CI (`.github/workflows/ci.yml`) runs that same script
- Command: `npx vitest run src/auth` — the scoped form of that script
- Exit code: 0

## Acceptance Criteria Evidence

| Criterion | Evidence | Pass/Fail |
|---|---|---|
| 1. A valid email + password returns 200 and a session token | `POST /auth/login` against the running dev server → `200 {"token":"eyJ..."}`; `login.test.ts` (4 tests) passed | Pass |
| 2. A wrong password returns 401 and no token | `login.test.ts` case "rejects a wrong password" passed | Pass |
| 3. A missing password returns 401, not 500 | No test covers it. Manual call: `POST /auth/login {"email":"a@b.c"}` → `500 {"error":"Internal Server Error"}` | Fail |
| 4. Sessions expire after 24h | `session.test.ts` case "expired token is rejected" passed; TTL read as 86400 in src/auth/session.ts:12 | Pass |

## Failures

### Criterion 3 — missing password returns 500

- Command: `curl -s -XPOST localhost:3000/auth/login -d '{"email":"a@b.c"}'`
- Output:

      {"error":"Internal Server Error"}
      TypeError: Illegal arguments: string, undefined
          at login (src/auth/login.ts:47:22)

- Cause hypothesis: `password` is read from the body without a presence check,
  so `undefined` reaches `bcrypt.compare` and throws. Evidence for the
  hypothesis: the stack frame at src/auth/login.ts:47 is the compare call, and
  the handler has no validation before it.

Hand to `/fix`: `/fix TASK-003`

## Gaps

- Criterion 3 has no automated test; the failure above was observed manually.
  A test belongs at src/auth/login.test.ts next to "rejects a wrong password".
- Rate limiting (SPEC 8.2) is out of this task's criteria and was not checked.

## Status

Tested: false
```

## Field rules

- **Environment** — four fields, in the order the project template declares
  them: the framework detected, **how it was detected** (the file that proves
  it), the exact command run, and its exit code. The "how it was detected" line
  is what lets the next reader audit the choice of command; without it the whole
  record is untrustworthy.
- **Acceptance Criteria Evidence** — one row per acceptance criterion, copied
  from the phase file in the task's own order, with columns `Criterion |
  Evidence | Pass/Fail`. Evidence is the command output or the observation, not
  an assertion that it works. A criterion split into several runs gets several
  clauses in its Evidence cell.
- **Failures** — one entry per failing criterion or test: the command, the
  output verbatim, and a **cause hypothesis**. A symptom restated is not a
  hypothesis: say what in the code or configuration would produce this, and
  cite the frame, line or setting that supports it. End with the `/fix` command
  to hand it over.
- **Gaps** — criteria with no evidence, and why: no test exists, the feature
  cannot be exercised here, the environment lacks a dependency. "No gaps"
  when there are genuinely none.
- **Status** — exactly one line, `Tested: true` or `Tested: false`. It must
  match the phase file's `Tested` box. See `task-state.md`.

## Rules for the verdict

- **A flaky test is not a pass.** Re-run once to judge flakiness; then record
  it as a failure (intermittent) either way, because it cannot support a
  verdict a later run might contradict.
- **A skipped, pending, or `todo` test is not a pass.** It records an intent to
  test, not a result.
- **A green suite unrelated to the task's criteria is not evidence.** The suite
  passing tells you your change broke nothing; it does not prove the criteria.
- **A harness error is a failure of the check**, not a pass by default — a
  missing dependency or broken import is a red result, not an absent one.
- **Failures are handed to `/fix`**, referenced as `TASK-NNN#…` when the failure
  maps to a review finding as well. Never silence, skip, delete or
  `.skip()` a test to make a check go green: the record you leave then certifies
  code you know is broken.
- **Do not fix while checking.** `/check` writes the record and stops; the fix
  belongs in `/fix`, which resets the boxes whose evidence its change
  invalidated.

## Re-checking after a fix

When `/fix` has run, re-check the task and update this file in place:

- Re-run the failing commands and record the new output. Update the Pass/Fail
  column of the affected rows to the new verdict.
- Move fixed failures out of **Failures** — an empty section with "None" is
  correct once the fix holds — and record in a short `## Re-check` note what
  was re-run and what changed since the previous pass, so the record shows why
  the verdict moved.
- Re-run the full criterion set, not only the criterion that failed. A fix
  changes code; other criteria's evidence may now be stale.
- Keep the history: the check file is the record of what was proved, and a
  verdict that changed without a trace of why is not a record.
