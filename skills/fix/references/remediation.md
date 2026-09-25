# Remediation

How to remove the cause of a finding rather than its symptom, how to keep the
change reviewable, and the exact format of `docs/fixes/TASK-NNN.md`.

## Root cause, not symptom

A finding names a symptom — an observed behaviour at one entry point. The cause
is usually one layer down, in code every entry point routes through.

```text
# The finding: POST /auth/login returns 500 when the password is missing.

# Wrong: guard the reported caller. Here `/auth/login`, tomorrow
# `POST /users/:id/password` gets the same 500.
app.post("/auth/login", (req, res) => {
  if (typeof req.body.password !== "string") return res.status(401).end();
  ...
});

# Right: guard the shared function both callers route through. One guard,
# every caller covered.
function requirePassword(body) {
  if (typeof body.password !== "string") throw new Unauthenticated();
  return body.password;
}
```

Guarding every caller instead of the shared function is a bigger diff and a
second bug: the callers you did not touch still fail, and nothing tells you so.

**Before editing, grep every caller of the function you are about to touch.**
If the cause lives in the shared function, fix it there. If several callers
each need different behaviour, the cause is not in the shared function — say
so, and fix the one the finding names.

## Scope rule

Fix the finding. Nothing else.

- A drive-by refactor while fixing makes the change unreviewable: the reviewer
  can no longer see which edit addressed which symptom, and `/check`'s re-run
  proves less because more changed.
- Renaming, reformatting or reorganising files you happened to open is a
  finding of its own, or a task of its own. Write it down and move on.
- An unrelated bug you stumble over: record it as a new finding on the task, or
  report it to the user for a new task — the choice depends on whether it
  affects this task's acceptance criteria.
- If a finding is "the code duplicates what already exists elsewhere", the fix
  is to use the existing thing — that is in scope, because it *is* the finding.

## When not to force the fix

Hand back to the user instead of remediating when any of these holds. Each of
them means the finding and the codebase disagree about what correct is, and
resolving that is not `/fix`'s call.

- **The fix invalidates the finding's own reproduction.** The finding described
  a scenario that really occurred; your change makes that scenario unreachable
  for a reason unrelated to the cause. Either the diagnosis was wrong or the
  fix is. State which you suspect.
- **The SPEC says the behaviour is intended.** Check section 9 (Business
  Logic), section 16 (Constraints) and section 18 (Decisions). The SPEC
  outranks a reviewer's preference; report the conflict and let the user
  decide whether to change the SPEC or the code.
- **The fix needs an acceptance criterion changed**, a public API broken, or
  user data migrated. Those are project decisions, and the request to make one
  should say so explicitly.
- **The finding asks for work outside this task's scope** and outside the
  SPEC's requirement — that is a new task, not a remediation.

## Conflicts between findings

Two findings fixed in one pass must not touch the same lines. Work through them
one at a time, re-reading the file before each edit: edits from the previous fix
now sit in that file, and the second fix must be planned against what is
actually there.

When two findings *do* need the same lines, fix the one that removes the cause,
then re-read to see whether the second is still a finding. Often one root-cause
fix retires two symptoms — say so in each record rather than duplicating the
change.

## Verify the original failure

Re-run the scenario that proved the problem. Not the whole suite as a proxy —
the actual command or steps:

- A finding from `/review`: re-run or re-read the scenario in the finding's
  `Problem:` field.
- A failure from `/check`: re-run the exact command recorded in
  `docs/checks/TASK-NNN.md`.

Record the new output. "Now works" without output is a claim, and `/review`
cannot re-confirm a claim.

## Format of `docs/fixes/TASK-NNN.md`

One file per task, at the path its ID names: TASK-003 → `docs/fixes/TASK-003.md`.

```markdown
# Fix — TASK-003

## FINDING-001 — Missing password reaches bcrypt and returns 500

Root cause: `login()` reads `req.body.password` at src/auth/login.ts:47 and
passes it to `bcrypt.compare` without a type check. The same pattern exists in
`resetPassword()` at src/auth/reset.ts:31 — grep for `bcrypt.compare` found
exactly these two callers, so the check belongs in the shared `readPassword()`
helper both now use.

Change:
- src/auth/credentials.ts — new `readPassword(body)` returning the string or
  throwing `Unauthenticated`.
- src/auth/login.ts:44-49 — call `readPassword(req.body)` instead of reading
  `req.body.password` inline.
- src/auth/reset.ts:29-33 — same replacement.

Verification:

    $ curl -s -XPOST localhost:3000/auth/login -d '{"email":"a@b.c"}'
    {"error":"invalid credentials"}   # 401, was 500 TypeError
    $ npx vitest run src/auth
     ✓ src/auth/login.test.ts (4 tests)
     ✓ src/auth/session.test.ts (3 tests)
     Tests  7 passed (7)

## FINDING-004 — Inconsistent error body for auth failures

Root cause: the login handler returned `{"error":"..."}` while the session
middleware returned `{"message":"..."}`; both consumers of the API had adapted
to the difference rather than the difference being fixed.

Change:
- src/auth/login.ts:58 — use the `{"message": ...}` shape the middleware uses.

Verification:

    $ curl -s -XPOST localhost:3000/auth/login -d '{"email":"a@b.c"}'
    {"message":"invalid credentials"}

## Result

Reset:
- `- [ ] Reviewed` — code changed in src/auth/credentials.ts, login.ts,
  reset.ts; the previous review judged code that no longer exists.
- `- [ ] Tested` — the criterion-2 evidence in docs/checks/TASK-003.md was
  captured against the old response body.

`Implemented` left checked: the task was implemented; these are defects in it,
not missing implementation.

Next: `/review TASK-003` and `/check TASK-003`.
```

### Field rules

- **Title** — `## FINDING-NNN — <short title>`, using the finding's own
  identifier from the review doc so `/review` can match record to finding. For
  a check failure with no finding, use the criterion it broke, e.g.
  `## Criterion 3 — missing password returns 500`.
- **Root cause** — the code and line that produces the failure, and the
  evidence that this is the cause rather than a nearby line: the stack frame,
  the grep result, the reproduction. If you could not establish the cause,
  write what you ruled out and stop rather than shipping a guess.
- **Change** — file by file, with line ranges where useful, and what changed in
  each. The reviewer reads this instead of the diff summary, so it must name
  every file touched.
- **Verification** — the exact command or scenario re-run, and its output, in a
  fenced or indented block. Real output, pasted.
- **Result** — which boxes were reset, and why, one line each. Call out
  explicitly any box left checked that a reader might expect to be reset, as in
  the example's `Implemented` note.

## Reference so `/review` can close the finding

`/fix` does not edit `docs/reviews/TASK-NNN.md`. It records the remediation
here, referencing the finding's identifier, and reports the task as back in
review. `/review` then reads this file, checks the verification against the code
as it now stands, and marks the finding `Fixed` — that re-confirmation is what
lets the `Reviewed` box flip. A fix recorded here is a claim; the review is the
proof.
