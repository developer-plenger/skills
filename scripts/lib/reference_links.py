"""Every references/*.md link a SKILL.md makes must resolve to a real file.

A SKILL.md may write a bare `references/foo.md` (relative to its own skill
directory) or a path-qualified `skills/plan/references/foo.md` (relative to the
repository root). Both are checked; a bare link is also checked against the
repository root, because a skill reaching across to another skill's reference is
legitimate and common.

Exits 0 when all resolve, 1 listing each broken link. No arguments; run from the
repository root.

    python3 scripts/lib/reference_links.py
"""

import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(".")
LINK = re.compile(r"(?<![\w/])((?:[\w./-]+/)?references/[a-z-]+\.md)")


def skill_files():
    out = subprocess.run(
        ["git", "ls-files", "skills/*/SKILL.md"],
        capture_output=True, text=True, check=True,
    ).stdout
    return [pathlib.Path(p) for p in out.split()]


def resolves(link, skill):
    """True when the link points at a file, tried the three places it may mean."""
    for candidate in (skill.parent / link, ROOT / link, ROOT / "skills" / link):
        if candidate.is_file():
            return True
    return False


def main():
    broken = []
    for skill in skill_files():
        for link in sorted(set(LINK.findall(skill.read_text()))):
            if not resolves(link, skill):
                broken.append(f"  FAIL {skill} -> {link} missing")

    if broken:
        print("\n".join(broken))
        return 1

    print("  ok   reference links resolve")
    return 0


if __name__ == "__main__":
    sys.exit(main())
