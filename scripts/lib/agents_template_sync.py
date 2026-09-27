"""templates/AGENTS.md must be the canonical text in agents-template.md, verbatim.

The two exist for different readers (a runtime reference and a copy-paste seed),
and the obvious way to update one is to forget the other. This fails loudly
instead.

Exits 0 when identical, 1 with a diff summary when not. No arguments; run from
the repository root.

    python3 scripts/lib/agents_template_sync.py
"""

import difflib
import pathlib
import re
import sys

REFERENCE = pathlib.Path("skills/init/references/agents-template.md")
TEMPLATE = pathlib.Path("templates/AGENTS.md")
BLOCK = re.compile(r"~~~~markdown\n(.*?)\n~~~~", re.S)


def main():
    match = BLOCK.search(REFERENCE.read_text())
    if not match:
        print(f"  FAIL no ~~~~markdown block in {REFERENCE}")
        return 1

    canonical = match.group(1)
    on_disk = TEMPLATE.read_text().rstrip("\n")

    if canonical == on_disk:
        print("  ok   identical")
        return 0

    print(f"  FAIL {TEMPLATE} drifted from the canonical text in {REFERENCE}")
    for line in difflib.unified_diff(
        canonical.splitlines(), on_disk.splitlines(),
        fromfile="agents-template.md", tofile="templates/AGENTS.md", lineterm="",
    ):
        print(f"       {line}")
    return 1


if __name__ == "__main__":
    sys.exit(main())
