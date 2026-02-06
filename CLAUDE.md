# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal profile + technical blog for Jeongseop Lim (임정섭), built with Hugo and the DoIt theme, deployed on Netlify. The site is bilingual (English primary, Korean secondary) and lives at <https://about.jseoplim.com/>.

## Commands

- **Local dev server**: `hugo server -D` (includes drafts)
- **Production build**: `hugo --gc --minify`
- **Markdown lint**: `markdownlint-cli2 "**/*.md"` (with `--fix` for auto-fix)
- **Compare language files**: `./scripts/compare-multi-lang.sh` (checks English/Korean parity)
- **Copy English to Korean**: `./scripts/copy-en-to-ko.sh` (runs automatically as pre-commit hook)

## Architecture

### Configuration

Hugo config uses the modular directory approach under `config/_default/`. Key files:

- `hugo.toml` — base config (baseURL, theme, features)
- `hugo.en.toml` / `hugo.ko.toml` — language-specific settings
- `params.toml` — theme parameters (author, social links, analytics, comments)
- `params.en.toml` / `params.ko.toml` — language-specific descriptions and subtitles
- `menu.en.toml` / `menu.ko.toml` — navigation menus

### Bilingual Content Strategy

English is the source of truth. Korean files are auto-generated copies via the `scripts/copy-en-to-ko.sh` pre-commit hook. Content files use suffix-based naming: `index.en.md` / `index.ko.md`. CI verifies parity with `scripts/compare-multi-lang.sh`.

Canonical URLs always point to English (`/`). Korean pages live under `/ko/`.

### Content Structure

- `content/_index.en.md` — homepage (profile with education, experience, research interests)
- `content/posts/{slug}/index.en.md` — blog posts
- `content/categories/`, `content/tags/`, `content/series/` — taxonomies

### Custom Layouts

- `layouts/home.html` — custom homepage template
- `layouts/_shortcodes/date.html` — language-aware date formatting (`{{< date "2026-03" >}}`)
- `layouts/_shortcodes/period.html` — language-aware date range (`{{< period from="2022-08" to="2024-08" >}}`)
- `layouts/_shortcodes/image-gallery.html` — responsive flexbox image gallery
- `layouts/_partials/format-date-*.html`, `format-period-*.html` — date/period formatting helpers

### Deployment

Netlify builds from `main` branch. Config in `netlify.toml` pins Hugo v0.152.2 and timezone Asia/Seoul. Old post URLs (pre-`/posts/` prefix) have 301 redirects configured.

## SEO Guidelines

See `.github/instructions/seo-master.instructions.md` for detailed SEO rules. Key points:

- Main page title: "Jeongseop Lim" (no descriptors like "Profile" or "Homepage")
- Korean page title: "임정섭"
- Blog post titles: "{Title} – Jeongseop Lim"
- No duplicate titles across pages
- Meta descriptions: 1-2 sentences, role-centric, not literary
- Entity name format when combined: "Jeongseop Lim (임정섭)"

## CI

GitHub Actions runs on every push:

1. `compare-multi-lang` — verifies English/Korean content files match
2. `markdown-lint` — validates all Markdown files

## Workflow

1. Edit content (English files are the source)
2. Pre-commit hooks auto-copy English to Korean and lint Markdown
3. Push to `develop`, create PR to `main`
4. Merge after Netlify deploy preview approval
