# Slice files and task state

## Folders and filenames

`specs/NN-<plan-slug>/slice/NN-pK/tasks.md`:

```text
specs/
  01-initial-build/            a plan folder, created by its own /plan run
    spec.md                    that plan's specification — what it builds
    slice/                     that plan's development stages
      01-p0/tasks.md           the tracer bullet
      02-p1/tasks.md
      03-p2/tasks.md
    reviews/TASK-003.md
    checks/TASK-003.md
    fixes/TASK-003.md
  02-monthly-budgets/          the next /plan run's folder
    spec.md
    slice/
      01-p0/tasks.md           its own p0 — stage numbering restarts per plan
      02-p1/tasks.md
  03-csv-export/
    spec.md
    slice/
      01-p0/tasks.md           its own p0 again
```

**The plan folder is the unit.** A plan owns its specification and its slices; two plans never share either. The `NN` prefix on the folder is the plan's number — `01` for the first `/plan` run, `02` for the second — and it never changes once written. Adding a plan appends the next number; existing plan folders are never renumbered, because `context.md`'s ledger, the slice paths and every review, check and fix document refer to them by name.

**Stage numbering restarts inside each plan.** `plan-02/slice/01-p0/` is the first stage of plan 02 and has nothing to do with `plan-01/slice/01-p0/`. That is deliberate: the stages exist to sequence one plan's work, so numbering them against a global counter would make "the third stage of plan 02" a subtraction problem.

`K` starts at `0` — `p0` is the tracer bullet, `p1` the next stage — because the first stage is the zero-th elaboration of the plan, not a phase of its own.

Stages are appended within their plan: a plan whose stages end at `03-p2` gets `04-p3`. **Never renumber or rewrite an existing stage**, and never move a stage between plans — reviews, checks, fixes and `context.md` all refer to them by folder name, so a renumber silently orphans every reference.

`/slice` is the only skill that creates `slice/` and its stage folders. `/plan` creates the plan folder and its `spec.md`, and stops there.

## Exact file shape

```markdown
# Slice 02-p1 — Authentication

## Objective

## Vertical Slice

## Tracer Bullet

## Dependencies

### BLOCKED BY

- TASK-001

### BLOCKS

- p2

## Tasks

### TASK-003 — Login endpoint

- [ ] Implemented
- [ ] Reviewed
- [ ] Tested

#### Description

#### Acceptance Criteria

- …

#### Dependencies

- TASK-001
```

Heading levels are load-bearing: `#` slice, `##` sections, `###` tasks and dependency sub-blocks, `####` task fields. `/exec` locates a task by grepping `### TASK-NNN`, so a task written with a different level will be missed.

The `#` heading names the folder, `Slice 02-p1 — <title>`, so a file read on its own still says which stage it is. The `## Objective` carries any deferrable open question inherited from the plan spec's §17, verbatim.

## Task numbering

`TASK-NNN`, zero-padded to three, **restarting at `TASK-001` inside every plan folder**. The plan folder is the namespace: `plan-02/slice/02-p1/tasks.md` may contain its own `TASK-003`, and that is a different task from `plan-01`'s `TASK-003`. Before writing, find the highest ID already used **in this plan**:

```
grep -rhoE 'TASK-[0-9]{3}' specs/NN-<plan-slug> | sort | tail -1
```

Numbering restarts because everything about a plan lives in the plan folder — its spec, its slices, its reviews, its checks, its fixes. A restart keeps a plan self-contained: `specs/02-monthly-budgets/reviews/TASK-003.md` and `specs/01-initial-build/reviews/TASK-003.md` are different files in different folders, so nothing collides and nothing has to be looked up across plans. What it costs is that a bare `TASK-NNN` no longer identifies a task on its own; every invocation carries the plan, and each skill's step 2 asks when it is ambiguous.

Within the plan, never reuse an ID, never skip one: IDs appear in review, check and fix filenames and inside task dependencies, so a collision inside one plan points at the wrong task. If a task is removed, its ID retires — do not fill the hole.

The three-digit width is load-bearing: `sort` compares text, so the command above is only correct while every ID has the same number of digits. A stray `TASK-9` hand-typed next to padded IDs sorts *after* `TASK-010` and becomes the printed answer, so pin the width in the pattern and let a violation fail to match rather than mis-order. Widen the padding rule and this pattern together if a plan ever reaches `TASK-1000` — a four-digit ID matches only its first three digits (`TASK-100`), so the command prints a wrong answer rather than failing loudly.

## Task sizing

One task = one coherent change with its own acceptance criteria, independent of its siblings. That means:

- It can be described without "and" joining two unrelated outcomes.
- Its criteria can be checked without another task in the stage being done, apart from the ones in its own `#### Dependencies`.
- It fits a single focused session. If the description needs sub-headings to stay clear, it is two tasks.

Tasks inside a stage carry no ordering of their own beyond `#### Dependencies`; shared helpers needed by several tasks are their own task, depended on by each.

## Acceptance criteria

Criteria come from the requirement in **the plan's spec** that the task implements (§8 and §19), not from the implementation the author has in mind. Each criterion must be observable from outside the code — something a person or a test can check without reading the diff. Rewrite the requirement in the imperative and split it until each line passes this bar:

- **Observable**: names an input and an expected result. "Handle errors properly" fails; "submitting an empty email returns 400 with the field name" passes.
- **Falsifiable**: a stub implementation fails it. If the criterion holds on an empty function, it is not a criterion.
- **Bounded**: one behaviour per bullet, no "and also".
- **Spec-traceable**: you can point at the §8 requirement it comes from; if you cannot, either the criterion is invented or the spec is missing a requirement — report the latter rather than absorbing it.

Include the boundary or error case the requirement implies, and prefer a concrete example over an abstraction: "login with a wrong password returns 401 and does not create a session" beats "authentication is secure". Do not write testing steps here — `/check` turns criteria into evidence; these say *what must be true*.

## Why three boxes and not a `status:` field

Three independent booleans because the states are independently true: code that runs but is unreviewed and untested is a normal, useful position in the middle of a day. A single `status` cannot hold it without inventing a fourth value for every combination, and the first person in a hurry picks `done` because that is the only one that closes the ticket.

The three boxes are also the whole state. There is no `status:` field anywhere in the file, and none is to be added — **`DONE` is derived from all three being checked, never stored**. A stored `DONE` is a second source of truth that will disagree with the boxes the moment someone checks one.

## Who may flip which box

The boxes have exactly one owner each. `/slice` creates every task with all three unchecked and never flips them afterwards — it may amend the description or criteria of a task that has not been started, and must report a task it changed, but an implemented task's state belongs to the skills below.

| Box | Flipped by | Flipped only when |
| --- | --- | --- |
| `Implemented` | `/exec` | the changed path actually runs — not when it compiles |
| `Reviewed` | `/review` | no unresolved finding of severity Medium or higher remains |
| `Tested` | `/check` | every acceptance criterion has passing evidence |

Reset means writing `- [ ]` again. `/fix` resets exactly the boxes its change invalidated: a code change always resets Reviewed and Tested, and resets Implemented too if the fix shows the task was never really implemented.

## Locating a task

`TASK-NNN` restarts per plan, so it identifies a task only together with the plan
folder that holds it. Find it by grepping **the plan you are working in**:

```
grep -rn "^### TASK-003" specs/NN-<plan-slug>/slice
```

One hit, in a `### TASK-003 — …` heading: proceed — the path names the stage.
**Two or more hits inside one plan: stop and report.** A duplicated ID means review
and check artifacts point at one of several tasks, and picking one silently writes
state into the wrong place. The fix is a `/slice` amendment — renumber the
duplicate — not a guess by the calling skill.

Grep the plan folder, not all of `specs/`: the same ID legitimately exists in every
other plan that has been sliced, so a repository-wide grep returns one hit per plan
and the rule above would halt a plan with nothing wrong with it. Which plan to
write into is settled before the grep — each skill's step 2 resolves it, and asks
when a bare `TASK-NNN` is ambiguous.

The `^### ` anchor is load-bearing, not decoration: an unanchored grep also
matches every `#### Dependencies` edge and `### BLOCKED BY` reference, so a
well-formed plan returns several hits for one task and the rule above would halt
a plan with nothing wrong with it. Only a task heading defines a task.

## Amending a plan's stages after the first pass

A later `/slice` run on the same plan does not rewrite what exists. It reads the plan's `spec.md` for what is new, finds the highest existing `NN-pK` in that plan, and appends from the next free number. Tasks already written keep their IDs, their boxes and their wording; a task that has been started is never restated to match a changed mind — that is what `/fix` and a new task are for.

A later *plan* gets its own `slice/` and its own `TASK-001`. `/slice` never adds stages to an older plan on a newer plan's behalf: work the user asked for in plan 03 is planned and sequenced in plan 03, even when it depends on what plan 01 delivered.
