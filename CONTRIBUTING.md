# Contributing to the LTspice Reference

Thanks for helping improve the LTspice documentation. This repo has a few
non-obvious constraints — please read this before editing, because several of
them aren't visible from looking at a single file.

## How these files are used (read this first)

The Markdown files in [`ai_ref/`](ai_ref/) are consumed **two ways at once**:

1. **Rendered** as the GitHub Pages site:
   <https://analogdevicesinc.github.io/ltspice-reference/>
2. **Copied verbatim** onto users' machines by LTspice's `-init_ai_ref` command
   (see [`ai_ref/init_ai_ref.ps1`](ai_ref/init_ai_ref.ps1)), where local AI
   assistants read the raw `.md` files for guidance.

Every edit must therefore work in **both** contexts:

- Write content that reads correctly as rendered HTML **and** as raw Markdown fed
  to an LLM.
- Keep each section self-contained. Avoid visual-only phrasing ("click here", "see
  the box on the right") that means nothing to a text consumer.

## File encoding (highest-risk gotcha)

- **`.md` files are UTF-8.** Edit them with any normal text tool.
- **`.asc` schematic files are Windows-1252 encoded.** Do **not** edit them with
  UTF-8 text tools — doing so corrupts `µ` (0xB5) and other Windows-1252
  characters. Use a script with `encoding='latin-1'`, or re-copy the original and
  apply changes programmatically. See
  [`ai_ref/SCHEMATIC-REFERENCE.md`](ai_ref/SCHEMATIC-REFERENCE.md) for details.

## LTspice content conventions

- `1M` means **milli** (1e-3), **not** mega. Use `1Meg` for megaohms.
- Always write micro as `u` (1e-6) — **never** the `µ` symbol — in netlists,
  schematics, and code examples.
- Node `0` is always ground (`GND` is a synonym). Node names are case-insensitive.
- **Accuracy bar:** this documentation feeds AI assistants. Never fabricate or
  guess LTspice syntax. Verify against current LTspice behavior, or state
  explicitly that something is uncertain rather than inventing it.

## Frontmatter is required on every rendered page

Each Markdown file that renders on the site must begin with YAML frontmatter.
Without it the page loses its SEO metadata (`<title>`, meta description, Open
Graph tags).

```yaml
---
title: <concise page title>
description: <one-line summary; powers SEO meta and og: tags>
version: "24+"
---
```

New reference files should follow the existing structure:

1. Frontmatter (above everything)
2. `[← AI Reference](README.md)` back-link
3. A single `# H1` title
4. A one-line description paragraph

The two cheat-sheet files (`LTSPICE-KEYBOARD-SHORTCUTS.md`,
`LTSPICE-MENU-REFERENCE.md`) also carry `last_modified_at:` — update it when you
revise them.

## Do not remove the Jekyll theme overrides

These files exist deliberately to work around quirks in the `minima` theme.
Please don't delete them:

- [`_includes/header.html`](_includes/header.html) — suppresses minima's auto
  page-navigation strip. (`header_pages: []` in `_config.yml` does **not** work:
  Liquid's `default` filter treats an empty array as unset and falls back to
  listing all pages.)
- [`_layouts/page.html`](_layouts/page.html) — removes minima's injected
  duplicate title `<h1>` (the body already has its own H1).
- The root `README.md` and `ai_ref/README.md` use `permalink:` (and the root uses
  `layout: page`) so they render as directory indexes (`/` and `/ai_ref/`).
  Without the permalinks those URLs 404.

## Adding or removing a reference file

A new document must be listed in **three** places to stay consistent (the
sitemap updates automatically):

1. The reference table in [`ai_ref/README.md`](ai_ref/README.md)
2. The reference table in the root [`CLAUDE.md`](CLAUDE.md)
3. The AI discovery index [`llms.txt`](llms.txt)

When removing a file, remove it from all three.

## Cross-linking convention

Link between reference files using **relative `.md` links**, e.g.
`[Troubleshooting](TROUBLESHOOTING-GUIDE.md)`. The `jekyll-relative-links` plugin
rewrites these to `.html` on the rendered site, and they remain valid when the
raw Markdown is read locally.

## Verifying your change

GitHub Pages rebuilds from the published branch and takes roughly a minute. After
your change is deployed, sanity-check the rendered output:

- The page renders with a single title (no duplicate H1).
- Cross-links resolve to the correct pages.
- Root URLs `/` and `/ai_ref/` load (no 404).
- `llms.txt`, `robots.txt`, and `sitemap.xml` return 200 if you touched site
  configuration.

## Questions

For LTspice usage questions (not documentation changes), see the
[LTspice forum](https://ez.analog.com/design-tools-and-calculators/ltspice/).
