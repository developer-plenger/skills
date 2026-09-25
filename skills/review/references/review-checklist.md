# Review Checklist

The dimensions to work through while reviewing a task, the severity scale that
classifies what you find, and the bar a claim must clear before it counts as a
finding.

Work the dimensions in this order. Stop a dimension as soon as the code
supports it; you are looking for the worst few real problems, not a complete
catalogue of everything imperfect.

## 1. Requirement compliance

- Does the code do what SPEC section 8 requires of this feature, and satisfy
  SPEC section 19 for it?
- Does every acceptance criterion in the phase file map to a code path that
  satisfies it, including the behaviour a criterion implies but does not spell
  out (a required field that must be rejected, an empty list that must return
  `[]` rather than error)?
- Are the **criteria the task forgot** covered — the ones in the SPEC that this
  task descends from but its acceptance criteria never restate?
- Is any criterion satisfied by a stub, a hardcoded value, or a branch that can
  never execute?
- Was something outside the SPEC built instead? Extra behaviour is not a
  bonus: unrequested scope is unreviewed scope. Report it as a Low or Medium
  finding against scope, not as praise.

## 2. Logic correctness

- Every branch reachable, and no branch that should exist is missing (the
  `else` of a validation, the failure arm of a protocol handler)?
- Boundaries: off-by-one, `<` vs `<=`, first and last element, empty input,
  single-element input, maximum size.
- Empty, null, undefined, zero and whitespace-only inputs handled?
- Ordering assumptions — does the code rely on iteration or insertion order
  that the data structure does not guarantee?
- Arithmetic and money: integer vs float, rounding, division by zero,
  accumulation across retries.
- State transitions: can the code reach a state it cannot leave?
- Time: timezone, clock skew, DST, timestamp comparison across units.
- Concurrency where it exists: two requests racing the same row or file,
  double submission, lost update.
- Does the result match what the SPEC says the output should be when the input
  is valid?

## 3. Architecture

- Does the change fit the structure that already exists, or does it add a
  parallel one — a second HTTP client, a second error type, a second config
  loader next to the ones the repo already has? Duplicating an existing
  abstraction is a Medium finding even when the new code works.
- Are the seams right: does a caller know more about an internals than it
  should, does a leaf module reach upward into a layer above it, is business
  logic embedded in a controller or view?
- Is the dependency direction still one way, or did this change create a cycle?
- Does it add a dependency for something the platform, the standard library, or
  an installed package already does?
- Is the abstraction earned — one implementation behind an interface is
  guesswork until a second forces it?

## 4. Security

- Every input crossing a trust boundary validated and typed (request body,
  query, header, cookie, file upload, webhook payload, CLI argument)?
- Authorization on **every** path, not just the one route the task named —
  check the sibling handlers that share the resource.
- Injection: SQL via string concatenation, shell command built from input,
  template injection, path traversal from a user-supplied filename, SSRF from a
  user-supplied URL, deserialization of untrusted data.
- Secrets: any credential, token or key in source, logs, error messages or
  fixture data? Configuration read from an environment or secret store rather
  than committed?
- Data exposure: does a response or log line carry fields the caller is not
  entitled to — password hashes, internal IDs, other users' rows, stack traces?
- Authentication and session handling: token lifetime, revocation, password
  storage (a real KDF, not a bare hash).
- Does this code weaken a control the SPEC's Security Requirements (section 12)
  requires?

## 5. Maintainability

- Names say what the thing is or does, in the vocabulary the repo already uses?
- Dead code, unused imports, unreachable branches, commented-out blocks,
  debug output left behind?
- Duplication of a helper, type or pattern that already exists a few files
  over — the most common form of accidental complexity.
- Comment noise: a comment restating the line below it is noise; a comment
  explaining a non-obvious why is signal.
- Would the next person changing this file have to read three other files to
  understand it? Is that inherent to the problem or an artifact of the layout?
- A simplification that trades one of correctness, a boundary, an error path or
  a security control for brevity — that is not lazy, it is a regression.

## 6. Edge cases and error handling

- Failure paths: every external call — network, filesystem, database, queue —
  has a defined behaviour when it fails, times out, or returns partial data.
- Partial writes: if it fails halfway, is the system left consistent, or is the
  half-state silent?
- Retries: idempotent, or do they duplicate work and side effects?
- Errors surfaced or swallowed — a caught exception that is logged and
  discarded turns a loud failure into a quiet one.
- Error messages: do they tell the operator what failed, without leaking
  internals to the caller?
- Cleanup on the failure path: file handles, connections, transactions,
  temporary files.
- What happens on the second invocation — is state left behind that breaks
  re-running?

## 7. Performance

Apply this dimension only where SPEC section 13 (Scalability Considerations)
sets a bar, or where the code clearly does not scale with its input.

- Query count per request — an N+1 loop over rows the code just fetched.
- Work inside a loop that could be hoisted out of it.
- Unbounded growth: lists, caches or buffers with no cap, a query with no
  limit, a log written per item.
- Payloads loaded fully into memory when streaming is what the data size
  requires.
- Missing index behind a hot query the SPEC names.

Do not raise performance findings against code with no stated bar and no
realistic large input; that is style preference wearing a severity label.

## Severity

| Severity | Decides when |
|---|---|
| **Critical** | Data loss, a security hole, or a crash on a normal path. The system is unsafe to ship. |
| **High** | Violates a stated acceptance criterion, or breaks an existing caller of code this change touched. |
| **Medium** | A real edge case or maintainability risk that will bite: unvalidated boundary input, a duplicated abstraction, a swallowed error, a slow path the SPEC names. |
| **Low** | Style, naming, polish. Worth writing down; never a reason to hold the task back. |

Severity is about consequence, not effort: a one-line fix that prevents a lost
write is Critical, and a large refactor that only tidies naming is Low.

## What counts as a finding

A finding must carry all three:

1. **Location** — `path/to/file.ext:line`, or the function name when the line
   will move.
2. **The failing scenario** — concrete inputs or steps, and the outcome
   observed. "Not robust enough" is not a scenario. "POST /login with
   `password: null` reaches `bcrypt.compare(null, hash)` and throws a 500
   instead of returning 401" is.
3. **The change that would satisfy it** — the shape of the fix, in one or two
   sentences. You are not writing the patch; you are making the fix
   actionable.

A reviewer's opinion without a scenario is not a finding. Demote it to a note
in Recommended Changes, or drop it.

**A review with zero findings must say what it actually verified**, not merely
that nothing was wrong: the criteria checked, the files read, what was run.
"Looks good" is a vacuous approval and leaves the next reader unable to tell
whether the code was examined or skimmed.
