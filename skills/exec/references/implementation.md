# Implementing a task

## Find the code the task touches

Search for the feature, do not open guessed paths. In order:

1. Task files if named, plus the phase's other tasks — they often create the
   function you are about to edit.
2. The feature's existing entry point: the route table, the CLI command
   registration, the export barrel. That is where the repo declares what exists.
3. A search for the domain term across the source tree, then follow imports
   inward from the first real hit.

Then read the neighbours of the code you will change, in full enough to see their
conventions. **Follow the pattern already in the repo**: the same module layout,
the same error type, the same naming, the same dependency injection. Reuse
existing helpers, validators, and constants before writing new ones — a
second implementation of something already in the tree is the most common
middle-of-the-day mistake, and it costs the reviewer the job of spotting it.

If two patterns coexist in the repo, follow the one used by the code nearest
your change, and say in your report which you chose, so nobody has to guess
whether you saw the other one.

## Scope

The task's `#### Description` and `#### Acceptance Criteria` are the whole
scope. Everything else is out of scope, however obviously needed:

- a bug you noticed on the way — report it in a note;
- a helper the *next* task will want — report it;
- a refactor that would make your change prettier — report it;
- a dependency upgrade, a formatting change, a rename — report it.

A needed-but-unrequested change becomes **a note in the report, not an edit**.
Scope creep is not about size: it is that nobody asked for the change, so nobody
reviewed it, and it lands in the diff under a task ID that claims otherwise.
Reviewers check the task against its criteria; extra edits break that check and
are the usual source of "why is this in here?".

The reverse also holds: do not shrink the task. If a criterion is hard, that is
the work.

## When a test belongs in the task

Add a test as part of `/exec` when **the acceptance criterion cannot be observed
without one** — the behaviour is not reachable from a command line, a running
app, or a manual smoke step you can perform (a race, a parse edge case, an
internal branch, a money calculation).

Otherwise leave testing to `/check`, which owns the `Tested` box and turns every
criterion into evidence. Do not write a test suite "to be safe", and do not run
the whole project's tests to close one task's box; both delay the task and
duplicate work that `/check` will do properly.

When you do add a test, it follows the repo's existing test conventions — the
same runner, the same location, the same style. A test in a new framework is not
the task, it is a new testing setup.

## Editing discipline

- **Smallest coherent change.** Every line in the diff should be traceable to
  the description or a criterion. If it is not, it is a note.
- **No drive-by refactors.** Do not rename, reorganise, or "clean up while you
  are here", even in files you are editing. `/review` reads the diff expecting
  task scope.
- **No reformatting untouched code.** No reindenting the block above your change,
  no reordering imports you did not add, no line-ending or whitespace churn. It
  hides the real change and breaks `git blame`.
- **Project conventions over personal preference.** If the repo uses tabs and
  long lines, use tabs and long lines. Match the surrounding code, not your
  usual style, and not a linter the project has not adopted.
- **Do not touch another task's territory.** If fixing your criterion requires
  changing what a sibling task owns, report it rather than editing it.

## When the task description turns out to be wrong

Sometimes the code shows the description cannot be implemented as written: the
endpoint it names does not exist, two criteria contradict each other, the
described design breaks an existing caller, or the requirement behind it was
misunderstood.

**Stop, report, and propose a `/slice` amendment — do not silently redefine the
task.** Silently implementing "the sensible version" replaces the plan with
whatever the implementer guessed, and the phase file then describes something
nobody built: the next task slices against the old text, `/review` checks the
wrong criteria, and the spec drifts one silent correction at a time.

In practice: stop before writing the wrong change; keep any work that still
matches the description; report the conflict with the evidence (the file, the
existing caller, the failing assumption); propose the amended description or
criteria; and let `/slice` apply it and re-decide the affected phase. If the user
waives the amendment, note that in the report — a small, purely local ambiguity
may be resolved in the description's own words, and the report must say so.
