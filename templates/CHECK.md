# Check — TASK-001

<!-- Lives at specs/NN-<plan-slug>/checks/TASK-001.md, inside the plan folder that
     holds the task. Task IDs restart per plan, so the plan folder is what makes
     this filename unique. -->

## Environment

- Framework detected: {{the test framework found in this repository}}
- How it was detected: {{the file or config that proves it, for example `package.json`, `go.mod`, or the pytest configuration}}
- Command: {{the exact command that was run}}
- Exit code: {{the exit code that command returned}}

## Acceptance Criteria Evidence

| Criterion | Evidence | Pass/Fail |
| --- | --- | --- |
| {{criterion copied from the task block}} | {{test name, command output, or direct observation}} | {{Pass or Fail}} |

## Failures

One entry per failing criterion or test. Output verbatim, then a cause hypothesis that cites what in the code produces it. End by handing it to `/fix`.

### Criterion {{N}} — {{what fails}}

- Command: {{the command that failed}}
- Output:

      {{the output, verbatim}}

- Cause hypothesis: {{what in the code or configuration would produce this, citing the frame, line, or setting that supports it}}

Hand to `/fix`: `/fix NN-<plan-slug>/TASK-001`

## Gaps

{{Criteria with no evidence, and why: no test exists, the feature cannot be exercised here, the environment lacks a dependency. Write "No gaps" when there are genuinely none.}}

## Status

Tested: false
