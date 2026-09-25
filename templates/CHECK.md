# Check — TASK-001

## Environment

- Framework detected: {{the test framework found in this repository}}
- How it was detected: {{the file or config that proves it, for example `package.json`, `go.mod`, or the pytest configuration}}
- Command: {{the exact command that was run}}
- Exit code: {{the exit code that command returned}}

## Acceptance Criteria Evidence

| Criterion | Evidence | Pass/Fail |
| --- | --- | --- |
| {{criterion copied from the task}} | {{test name, command output, or direct observation}} | {{Pass or Fail}} |

## Failures

One entry per failing criterion or test. Output verbatim, then a cause hypothesis that cites what in the code produces it. End by handing it to `/fix`.

### Criterion {{N}} — {{what fails}}

- Command: {{the command that failed}}
- Output:

      {{the output, verbatim}}

- Cause hypothesis: {{what in the code or configuration would produce this, citing the frame, line, or setting that supports it}}

Hand to `/fix`: `/fix TASK-001`

## Gaps

{{Criteria with no evidence, and why: no test exists, the feature cannot be exercised here, the environment lacks a dependency. Write "No gaps" when there are genuinely none.}}

## Status

Tested: false
