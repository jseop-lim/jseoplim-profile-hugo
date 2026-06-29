---
name: verify-json-ld
description: >-
  Build this Hugo site and validate the JSON-LD structured data it emits — valid JSON, resolvable @id links, no JSON-LD on noindex pages, and the expected schema.org entities per page type (home/post/posts-section, both languages). Use this whenever JSON-LD, structured data, schema.org, rich results, or the SEO `<head>` are touched — e.g. after editing `layouts/_partials/head/seo.html` or the `[person]` block in `config/_default/params.toml`, before pushing SEO changes, or when asked to "check / verify / validate the structured data (or JSON-LD)". Prefer this over hand-rolling a one-off build-and-grep.
---

# Verify JSON-LD

This site's JSON-LD is generated in `layouts/_partials/head/seo.html` (a DoIt theme override). Because it is template-driven, a small template change can silently break the markup on a whole class of pages. This skill rebuilds the site and checks the emitted markup so regressions surface immediately.

## How to run

From the repo root:

```bash
python3 .claude/skills/verify-json-ld/scripts/validate.py
```

It builds with `hugo --gc --minify --cleanDestinationDir` (the clean flag drops orphaned HTML from deleted/renamed content, which would otherwise read as false positives), then scans every page in `public/`. Exit code is non-zero on any failure, so it also works as a pre-push or CI gate.

Pass `--no-build` to validate an existing `public/` without rebuilding (faster when you just built).

## What it checks

**Structural invariants** (hold regardless of design):

- Every `application/ld+json` block parses as valid JSON.
- Every `@id` _reference_ resolves to a node defined somewhere on the site. Resolution is site-wide on purpose: Google merges entities by `@id` across pages, so a paginated page referencing `#person` without redefining it is fine, but a typo or stale URL (e.g. an old domain) is caught.
- noindex pages emit **zero** JSON-LD — putting structured data on pages that won't be indexed has no SEO value.

**Per-page-type expected entities** (the current design contract):

| Page kind     | Required `@type`s                         |
| ------------- | ----------------------------------------- |
| home          | `WebSite`, `ProfilePage`, `Person`        |
| posts section | `Blog`, `Person`                          |
| post          | `BlogPosting`, `BreadcrumbList`, `Person` |

Both English and Korean pages are covered automatically — the script walks every built page and classifies it by path (`noindex` wins over everything).

## When checks fail

Read each line: it names the page and the problem. Common causes:

- _missing expected @type_ — a template branch didn't fire for that page kind; check the relevant `if`/`else if` in `seo.html`.
- _dangling @id reference_ — a node references an entity that is never defined (often a stale/old-domain URL, or a `@type` dropped from a definition).
- _noindex page has N blocks_ — the page branch isn't gated on `not .Params.noindex`.

## When the design intentionally changes

If you deliberately add/remove an entity (e.g. start emitting `Article` on a new section), update the `EXPECTATIONS` map at the top of `scripts/validate.py` and the page-kind classification in `classify()` so the contract matches reality. The script is the executable spec for what this site's JSON-LD should contain.
