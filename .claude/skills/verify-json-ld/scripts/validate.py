#!/usr/bin/env python3
"""Validate the JSON-LD that Hugo emits for this site.

Builds the site (unless --no-build), then parses every `application/ld+json`
block out of `public/` and checks three things:

1. Structural invariants that hold regardless of design:
   - every block is valid JSON
   - every `@id` *reference* resolves to a node defined somewhere on the site
     (Google merges entities by `@id` across pages, so a paginated page may
     reference `#person` without redefining it — that is fine)
   - noindex pages emit no JSON-LD at all (it has no SEO value there)

2. Per-page-type expected entities (the current site design — edit
   EXPECTATIONS below if the design intentionally changes). Covers both
   languages automatically by walking every built page.

Exit code is non-zero if any check fails, so it doubles as a CI/pre-push gate.
"""

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

# Page kind -> @type entities that must be present. This is the regression
# contract for the current design; update it deliberately when the design does.
EXPECTATIONS = {
    "home": ["WebSite", "ProfilePage", "Person"],
    "posts_section": ["Blog", "Person"],
    "post": ["BlogPosting", "BreadcrumbList", "Person"],
}

LD_BLOCK = re.compile(
    r'<script type=["\']?application/ld\+json["\']?>(.*?)</script>', re.S
)
NOINDEX = re.compile(r'name=["\']robots["\'][^>]*content=["\'][^"\']*noindex', re.I)


def classify(relpath: str, html: str) -> str:
    """Map a built page to a kind. noindex wins over everything else."""
    if NOINDEX.search(html):
        return "noindex"
    if relpath in ("index.html", "ko/index.html"):
        return "home"
    if relpath in ("posts/index.html", "ko/posts/index.html"):
        return "posts_section"
    if re.fullmatch(r"(ko/)?posts/[^/]+/index\.html", relpath):
        return "post"
    return "other"  # pagination, taxonomies that are indexed, etc.


def walk(node, defined: set, refs: list):
    """Collect defined @ids (nodes with @type) and pure @id references."""
    if isinstance(node, dict):
        if "@id" in node and isinstance(node["@id"], str):
            if "@type" in node:
                defined.add(node["@id"])
            else:
                refs.append(node["@id"])
        for v in node.values():
            walk(v, defined, refs)
    elif isinstance(node, list):
        for v in node:
            walk(v, defined, refs)


def types_in(objs) -> list:
    """Flatten all @type values across blocks (handles @graph)."""
    found = []

    def rec(node):
        if isinstance(node, dict):
            t = node.get("@type")
            if isinstance(t, str):
                found.append(t)
            for v in node.values():
                rec(v)
        elif isinstance(node, list):
            for v in node:
                rec(v)

    for o in objs:
        rec(o)
    return found


def check_page(relpath: str, html: str, failures: list, defined: set, refs: list):
    """Validate one page; accumulate site-wide @id defs/refs for a later pass."""
    kind = classify(relpath, html)
    raw_blocks = LD_BLOCK.findall(html)

    # noindex: must be empty.
    if kind == "noindex":
        if raw_blocks:
            failures.append(f"{relpath}: noindex page has {len(raw_blocks)} JSON-LD block(s), expected 0")
        return

    # Parse every block; collect objects.
    objs = []
    for i, raw in enumerate(raw_blocks):
        try:
            objs.append(json.loads(raw))
        except json.JSONDecodeError as e:
            failures.append(f"{relpath}: block {i} is invalid JSON ({e})")

    # Accumulate @id definitions and references for the site-wide pass.
    for o in objs:
        page_refs = []
        walk(o, defined, page_refs)
        refs.extend((relpath, r) for r in page_refs)

    # Per-page-type expected entities.
    if kind in EXPECTATIONS:
        present = set(types_in(objs))
        for t in EXPECTATIONS[kind]:
            if t not in present:
                failures.append(f"{relpath}: missing expected @type {t!r} for {kind} page (present: {sorted(present)})")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--no-build", action="store_true", help="validate existing public/ without rebuilding")
    ap.add_argument("--public", default="public", help="built site directory (default: public)")
    args = ap.parse_args()

    if not args.no_build:
        # --cleanDestinationDir drops orphaned HTML from deleted/renamed content,
        # which would otherwise show up as stale false positives.
        print("Building site (hugo --gc --minify --cleanDestinationDir)...")
        r = subprocess.run(["hugo", "--gc", "--minify", "--cleanDestinationDir"], capture_output=True, text=True)
        if r.returncode != 0:
            print(r.stdout)
            print(r.stderr, file=sys.stderr)
            print("\n❌ Hugo build failed.", file=sys.stderr)
            return 1

    public = Path(args.public)
    if not public.is_dir():
        print(f"❌ {public}/ not found. Build first or pass --public.", file=sys.stderr)
        return 1

    failures, pages, with_ld = [], 0, 0
    defined, refs = set(), []  # site-wide @id definitions and (page, ref) pairs
    for f in sorted(public.rglob("index.html")):
        rel = f.relative_to(public).as_posix()
        html = f.read_text(encoding="utf-8")
        pages += 1
        if LD_BLOCK.search(html):
            with_ld += 1
        check_page(rel, html, failures, defined, refs)

    # Site-wide @id resolution.
    for relpath, r in refs:
        if r not in defined:
            failures.append(f"{relpath}: dangling @id reference {r!r} (not defined anywhere on site)")

    print(f"\nScanned {pages} pages ({with_ld} with JSON-LD).")
    if failures:
        print(f"\n❌ {len(failures)} problem(s):\n")
        for msg in failures:
            print(f"  - {msg}")
        return 1
    print("\n✅ All JSON-LD checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
