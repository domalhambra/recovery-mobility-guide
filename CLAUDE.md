# Badwater Mobility — Project Guide

## What this is
A static Hugo site — a practical reference library for mobility and recovery
exercises, organized by body region. The design is inspired by johnnydecimal.com
(clean, typographic, minimal) with the color palette from badwater.group.

**Live site:** https://mobility-guide.netlify.app/
**Repo:** github.com/domalhambra/recovery-mobility-guide

## Stack
- Hugo (extended, v0.157.0+) with Hugo Relearn Theme (git submodule in `themes/`)
- Pagefind for client-side search (built at deploy time)
- Netlify for hosting
- GitHub for version control

## Build commands
- `make dev` or `hugo server --buildDrafts` — local dev server on :1313
- `make build` or `hugo && npx -y pagefind --site public` — production build
- `make clean` — remove `public/`
- Netlify runs: `hugo --environment production && npx -y pagefind --site public`

## Content structure
All content is in `content/`, organized by body region:
```
content/
  _index.md                          # Homepage
  lower-body/                        # 10-19 area
    hips/, knees/, ankles/
  upper-body/                        # 20-29 area
    shoulders/, thoracic/, wrists-and-elbows/
  spine-and-core/                    # 30-39 area
    lumbar/, core-stability/
  routines/                          # 40-49 area (pre-built sequences)
    morning-flow/, desk-worker-reset/, post-workout/
  concepts/                          # 50-59 area (reference/explainer pages)
```

**Every folder MUST have an `_index.md`** or it won't appear in the sidebar.

## Front matter conventions
Exercise pages use this template:
```yaml
---
title: "Exercise Name"
description: "One sentence for SEO."
menuPre: "11.01 "
weight: 10
tags: ["body-region", "modality", "difficulty"]
---
```

- `weight` controls sidebar sort order (lower = higher). Use increments of 10.
- `menuPre` is the JD number shown before the title in the sidebar. Include trailing space.
- `tags` array — include one of each:
  - **Body region:** hips, knees, ankles, shoulders, thoracic, spine
  - **Modality:** flexibility, strength, foam-rolling, breathing, nerve-glide
  - **Difficulty:** beginner, intermediate, advanced
- The difficulty tag auto-generates a colored badge (green/yellow/red) via
  `content-header.html`. No separate `difficulty` field needed.

## Theme customization

### Color scheme
Two custom variants matching the badwater.group palette (warm earth tones):
- `assets/css/theme-mobility.css` — light mode
- `assets/css/theme-mobility-dark.css` — dark mode
- `assets/css/chroma-mobility.css` — syntax highlighting (Nord-based)

Three-way switching (Light / Auto / Dark) is configured in `hugo.toml` via
`[[params.themeVariant]]` entries. The custom toggle UI lives in
`layouts/partials/sidebar/element/variantswitcher.html`.

Key colors:
- Light: bg `#F7F3EE`, text `#2A2520`, links `#B84A28`
- Dark: bg `#1A1714`, text `#E8E2D8`, links `#D4734E`

### Typography
Set in `layouts/partials/custom-header.html`:
- **Body text:** Source Serif 4 (variable, serif)
- **Titles, sidebar, UI:** Inter (variable, sans-serif)
- Both loaded from Google Fonts with `font-display: swap`

### Layout & styling (all in custom-header.html)
- Content max-width: 50rem
- Dynamic sidebar: `width: fit-content`, min 14rem, max 21rem
- Sidebar body margin synced via JS MutationObserver
- Active sidebar item: right border instead of background highlight
- Compact sidebar spacing (0.1rem padding)
- Link highlight effect: terracotta underline on hover
- Centered inline TOC (max-width 24rem)
- Scroll progress bar (3px fixed at top)
- Search placeholder shows keyboard shortcut (Ctrl+Alt+F)
- JD-style footnotes section (border-top, muted, smaller text)
- Accessibility: focus-visible outlines, skip-to-content link, reduced motion,
  forced-colors support, WCAG touch targets

### Custom layout files
- `layouts/partials/custom-header.html` — fonts, all CSS overrides, JS for
  scroll progress bar, sidebar sync, and search placeholder
- `layouts/partials/content-header.html` — tags, difficulty badge, reading time,
  inline TOC
- `layouts/partials/sidebar/element/variantswitcher.html` — 3-state theme toggle
- `layouts/home/article.html` — homepage with floating link cloud

## Relearn theme gotchas
- The sidebar is `position: fixed` — body needs explicit `margin-left`
- The scroll container is `#R-body-inner`, NOT `#R-body` or `window`
- Built-in search shortcut is `Ctrl+Alt+F` (theme.js searchShortcutHandler)
- Font weight uses CSS custom properties like `--MAIN-TITLES-H1-font-weight`.
  Relearn's default Roboto Flex variation settings can conflict with other fonts.
- Theme variant files MUST be named `theme-{identifier}.css` matching the
  `identifier` in `hugo.toml`
- Tabs shortcode: outer `{{</* tabs */>}}` uses angle brackets, inner
  `{{%/* tab title="Name" */%}}` uses percent signs (for Markdown rendering)
- Notice shortcode: `{{%/* notice tip */%}}` / `{{%/* notice warning */%}}`

## Key configuration (hugo.toml)
- `alwaysopen = false` — sidebar sections collapsed by default
- `disableLandingPageButton = true` — no landing page button
- `disableInlineCopyToClipBoard = true` — no copy button on inline code
- `[markup.goldmark.renderer] unsafe = true` — allows raw HTML in Markdown
- `[markup.tableOfContents]` startLevel 2, endLevel 3

## What NOT to edit directly
- Anything in `themes/hugo-theme-relearn/` — it's a git submodule. Override via
  `layouts/` and `assets/` in the project root instead.
