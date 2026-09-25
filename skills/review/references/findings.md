# Review Document

The exact format of `docs/reviews/TASK-NNN.md`, the finding lifecycle, and how
to behave on a second review.

One file per task, at the path the task ID names: TASK-003 →
`docs/reviews/TASK-003.md`. Findings are numbered inside that file, from
`FINDING-001`, and referenced from anywhere as `TASK-003#FINDING-001`.

## Format

```markdown
# Review — TASK-003

## Summary

Login endpoint implemented; session issuance and validation present.
Criterion 3 (rate limiting) has no implementation. 4 findings: 1 High,
2 Medium, 1 Low.

## Findings

### FINDING-001

Severity: High
Status: Open
Location: src/auth/login.ts:42-58
Problem: `password` is read from the body without a presence check. A request
with `{"email":"a@b.c"}` reaches `bcrypt.compare(undefined, hash)` and returns
500; the route returns 401 for a wrong password and 200 for a correct one.
Why it matters: acceptance criterion 2 says a missing credential must be
rejected as unauthenticated. The 500 also distinguishes a malformed request
from a bad password, which hands an attacker a probe.
Suggested change: validate `email` and `password` as non-empty strings before
the lookup and return 401 with the same body used for a wrong password.

### FINDING-002

Severity: Medium
Status: Open
Location: src/auth/session.ts:88
Problem: `verifyToken` returns true when the token payload has no `exp` claim
— `payload.exp && Date.now() > payload.exp` short-circuits to false.
Why it matters: a token minted without an expiry (any token from another
issuer or an older deploy) is accepted forever.
Suggested change: treat a missing `exp` as invalid: `typeof payload.exp !==
"number"` → reject.

## Recommended Changes

1. FINDING-001 before merging — it changes the response contract.
2. FINDING-002 and FINDING-003 can go in one `/fix` pass; they touch
   different files.
3. FINDING-004 is cosmetic; fold it into the next change to that file.

## Verification

Read src/auth/login.ts, src/auth/session.ts, src/auth/middleware.ts and
src/routes/auth.ts in full. Ran `npx vitest run src/auth` — 7 passing, 0
failing, no test covers a missing password. Traced acceptance criteria 1 and 2
to lines 42 and 71; criterion 3 has no rate-limit code in the repository.

## Status

Reviewed: false
```

## Field rules

- **Summary** — two to four sentences: what the task appears to implement, how
  many findings by severity, and the one thing that most affects the verdict.
  Name the evidence examined; a summary that only says "reviewed" tells the
  next reader nothing.
- **Findings** — one `### FINDING-NNN` block per finding, numbered from 001 in
  the order you found them. Every block carries all six fields: `Severity`,
  `Status`, `Location`, `Problem`, `Why it matters`, `Suggested change`. A
  block that omits the location or the scenario is not a finding yet — finish
  it or drop it.
- **Recommended Changes** — the order the fixes should be applied, not a
  restatement of the findings. Call out where two fixes must not overlap, and
  which findings a single `/fix` pass can absorb.
- **Verification** — what you actually read or ran: files read in full,
  commands run with their result, criteria you traced to code. This is the
  review's evidence, and it is what makes a zero-finding review credible.
- **Status** — exactly one line, `Reviewed: true` or `Reviewed: false`. It
  must match the phase file's `Reviewed` box. See `task-state.md` for when
  `true` is allowed.

## Severity

Use the table in `review-checklist.md`. Critical = data loss, security hole, or
crash on a normal path; High = violates a stated acceptance criterion or breaks
an existing caller; Medium = a real edge case or maintainability risk that will
bite; Low = style and polish.

## Finding lifecycle

```text
Open  →  Fixed by /fix  →  re-confirmed by /review
```

- A finding starts `Status: Open`. Only `/review` writes the review doc, so
  only `/review` writes `Status`.
- `/fix` records its remediation in `docs/fixes/TASK-NNN.md` and references the
  finding from there. It does not edit the review doc.
- On the next `/review` of the same task, check whether each `Open` finding was
  actually remediated. If it was, set `Status: Fixed` and record in
  **Verification** what you read or ran that confirms it.
- **A finding that `/fix` claims to have fixed but this review has not
  re-confirmed stays `Open`** for every purpose, including the checkbox
  decision. A claim of a fix is not evidence of a fix.

## Re-review etiquette

When re-reviewing a task that already has a review file:

- Update findings in place: flip `Status` to `Fixed` with its confirmation, or
  leave it `Open` and say in **Verification** why the fix did not land.
- Add new findings as `FINDING-NNN+1` — never renumber the existing ones, and
  never delete a finding because it was fixed. A fixed finding is proof the
  process worked.
- Append to **Verification**; do not overwrite the previous pass. Keep the
  history: what changed between passes is the point.
- Revise **Summary** so it describes the current state. The summary may be
  rewritten freely — it is a snapshot, not a record.
