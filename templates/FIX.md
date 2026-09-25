# Fix — TASK-001

## FINDING-001 — {{short title, using the finding's own identifier from the review doc}}

Root cause: {{the code and line that produces the failure, and the evidence that this is the cause rather than a nearby line — the stack frame, the grep result, the reproduction. If the cause could not be established, write what was ruled out and stop rather than guessing.}}

Change:
- {{file path — what changed, with line ranges where useful}}
- {{file path — what changed}}
- {{file path — what changed}}

Verification:

    $ {{the exact command or scenario re-run}}
    {{its real output, pasted}}

## Criterion {{N}} — {{what fails}}

{{Use this heading instead when the input is a check failure with no review finding.}}

Root cause: {{the code and line that produces the failure, with the supporting evidence.}}

Change:
- {{file path — what changed}}

Verification:

    $ {{the exact command re-run}}
    {{its real output, pasted}}

## Result

Reset:
- `- [ ] Reviewed` — {{why the previous review judged code that no longer exists}}
- `- [ ] Tested` — {{why the previous evidence was captured against the old behaviour}}

{{State explicitly any box left checked that a reader might expect to be reset, and why. For example: `Implemented` left checked because the task was implemented and these are defects in it, not missing implementation.}}

Next: `/review TASK-001` and `/check TASK-001`.
