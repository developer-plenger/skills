#!/usr/bin/env bash
# Invariant check for the developer-plenger pack. No dependencies beyond git,
# grep and python3. Run from the repository root: ./scripts/check.sh
set -uo pipefail
cd "$(dirname "$0")/.."

fail=0
err() { printf '  FAIL %s\n' "$1"; fail=1; }
ok()  { printf '  ok   %s\n' "$1"; }

echo "1. manifests parse"
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
  python3 -c "import json,sys; json.load(open('$f'))" && ok "$f" || err "$f is not valid JSON"
done

echo "2. templates/AGENTS.md is the canonical text in agents-template.md"
python3 scripts/lib/agents_template_sync.py || fail=1

echo "3. no retirements left behind"
# Scanned: the files an agent or a user follows literally. Excluded on purpose:
# design-brief.md (archived input that narrates the old layout), scripts/ (this
# check names the patterns), README.md and the pack docs, which describe the
# migration rather than instruct anyone to use the old paths.
# Only README.md is exempt, and only because it documents this migration by
# naming the retired paths in prose. Everything else — the skills, the templates,
# the manifests, docs/ — is scanned.
RETIRED='docs/plan/|docs/phases|docs/reviews|docs/checks|docs/fixes|phase-NN-<slug>|PHASE\.md|/plans/plan-'
SCANNED=$(git ls-files | grep -v '^docs/design-brief.md$' | grep -v '^scripts/' | grep -v '^README.md$')
if rg -n "$RETIRED" $SCANNED >/dev/null 2>&1; then
  rg -n "$RETIRED" $SCANNED | sed 's/^/  FAIL /'
  fail=1
else
  ok "old layout fully retired"
fi

echo "4. every references/ link a SKILL.md makes exists"
python3 scripts/lib/reference_links.py || fail=1

echo "5. artifact shape counts"
[ "$(rg -c '^## ' templates/CONTEXT.md)" = 14 ] && ok "context.md has 14 sections" || err "context.md section count changed"
[ "$(rg -c '^## [0-9]+\.' templates/SPEC.md)" = 19 ] && ok "spec.md has 19 sections" || err "spec.md section count changed"
[ "$(rg -c '^## ' templates/DESIGN.md)" = 10 ] && ok "design.md has 10 sections" || err "design.md section count changed"
[ "$(rg -c '^### ' skills/init/references/agents-template.md)" -ge 8 ] && ok "all eight skills registered in the contract" || err "a skill is missing from the AGENTS.md contract"
[ "$(ls templates/*.md | wc -l | tr -d ' ')" = 8 ] && ok "eight templates" || err "template count changed"

echo "6. no retired layout vocabulary left behind"
# Two retired models, both of which would silently corrupt every path:
#   multi-app     — many app folders under specs/, each shared across plans
#   single-spec   — one app folder holding one spec.md that later /plans amend
# The pack is: one folder per plan, each with its own spec.md and slice/.
RETIRED_APP='<NN-slug>|## Apps|Current Position|NN-nama-app|02-analytics|app blocks|## Plan record|plans/plan-NN|01-<slug>|one app per repository'
SCANNED_APP=$(git ls-files | grep -v '^docs/design-brief.md$' | grep -v '^scripts/' | grep -v '^README.md$')
if rg -n "$RETIRED_APP" $SCANNED_APP >/dev/null 2>&1; then
  rg -n "$RETIRED_APP" $SCANNED_APP | sed 's/^/  FAIL /'
  fail=1
else
  ok "one plan folder per /plan run, consistently"
fi

echo
[ "$fail" = 0 ] && echo "check.sh: PASS" || echo "check.sh: FAIL"
exit "$fail"
