# Lotus Docs Port — Design Spec

**Date:** 2026-05-03
**Project:** badwater.guide mobility (`24 mobility website development`)
**Branch / worktree:** `lotus-port` (sibling worktree at `../24-mobility-lotusdocs/`)
**Status:** Design approved, awaiting implementation plan

## Goal

Port the badwater.guide mobility site from Hugo Relearn to Hugo Lotus Docs as a clean rebuild that uses the new theme's defaults wherever possible, drops Relearn-era custom styling, upgrades the body map source SVG to a higher-quality MIT-licensed asset, and keeps the body-region-to-content navigation as the central UX deliverable.

## Why

The current Relearn build has accumulated three load-bearing pain points that are architectural, not cosmetic:

1. **CSS variable conflicts.** Relearn's `--MAIN-TITLES-*` variables and Roboto Flex variation settings fight Source Serif 4 + Inter. Specificity battles in `custom-header.html` are routine.
2. **Sidebar mechanics.** The sidebar is `position: fixed`, with body-margin sync via a JS MutationObserver, and the scroll container is a non-standard `#R-body-inner`. These are workarounds layered on the theme.
3. **Limited landing page flexibility.** Relearn is docs-only. The custom `home/article.html` and the body map system both fight the theme's content-type assumptions.

Lotus Docs (Bootstrap 5 + Sass, Hugo Module install, native landing-page partials, Bootstrap-grid sidebar) resolves all three by default. The remaining work is content migration plus a small custom layer for the body map.

A secondary motivation: a `git submodule` install of Relearn has historically been corrupted by iCloud (memory: `iCloud corrupts git submodules`). Lotus Docs installs as a Hugo Module, which sidesteps the issue entirely.

## Scope

**In scope:** install Lotus Docs as a Hugo Module in a clean worktree, migrate content / data / static assets, port the body map system with a new SVG source, configure Lotus's defaults, update build pipeline, cut over Netlify deployment.

**Out of scope:** new content authoring, custom Bootstrap theming beyond at most one accent-color override, Algolia DocSearch, i18n, comments, analytics, any feature not on the current live site.

## Approach

A side-by-side rebuild in a git worktree off `main`. The current site continues to deploy from `main` throughout. The port lands when verified, via merge.

Rejected alternatives:
- *In-place theme swap on a feature branch.* Single working tree, but harder to A/B compare and noisier git history during the rebuild.
- *Throwaway spike before commitment.* Useful as a de-risking step but not necessary — the body map system is well-specified enough that the unknowns are tractable inside the worktree itself.

## Pain points → resolutions

| Pain | Resolution |
|---|---|
| CSS variable conflicts (Relearn `--MAIN-TITLES-*` vs custom fonts) | Lotus uses Sass variables, no Roboto Flex baggage. Custom font overrides become a single Sass param if needed. |
| Sidebar `position: fixed` + JS sync hack | Lotus uses Bootstrap-grid sidebar in normal flow, no hacks. |
| Limited landing page (custom `home/article.html` to fit body map) | Lotus ships landing-page partials (`hero`, `feature_grid`, `image_compare`, `image_text`); homepage overrides via `layouts/index.html`. |
| Submodule + iCloud corruption | Hugo Module install, no submodule. |

## Section 1: Install

Worktree layout:

```
../24-mobility-lotusdocs/
  hugo.toml
  go.mod                  # Hugo Module manifest
  go.sum
  archetypes/             # ported
  content/                # ported
  data/                   # ported (body_regions.toml)
  static/                 # ported (SVGs, media)
  layouts/                # body map partial + homepage override only
  assets/                 # empty unless we override Bootstrap accent
  netlify.toml            # ported, build command updated
```

Hugo module declaration in `hugo.toml`:

```toml
[module]
  [[module.imports]]
    path = "github.com/colinwilson/lotusdocs"
  [[module.imports]]
    path = "github.com/gohugoio/hugo-mod-bootstrap-scss/v5"
```

Setup commands (one-time):

1. `git worktree add -b lotus-port ../24-mobility-lotusdocs main`
2. From the worktree: remove Relearn-era artifacts — `themes/`, `assets/css/theme-mobility*.css`, `assets/css/chroma-mobility.css`, `layouts/_default/`, `layouts/sidebar/`, `layouts/home/`, `layouts/partials/custom-header.html`, `layouts/partials/content-header.html`, `layouts/partials/menu-footer.html`, `layouts/partials/custom-footer.html`.
3. `hugo mod init github.com/domalhambra/recovery-mobility-guide`
4. Add the module imports above to `hugo.toml`, run `hugo mod get github.com/colinwilson/lotusdocs`.
5. `hugo server` — verify Lotus Docs renders against the existing content tree.

## Section 2: Content & data migration

**Ports wholesale:**

- `content/` (every body region tree, exercise, routine, concept page)
- `data/body_regions.toml`
- `static/` (excluding the soon-replaced `static/svg/body-front.svg` and `body-back.svg`)
- `archetypes/default.md`

**Front matter changes (single sed pass across content):**

- Strip leading `NN.NN ` JD prefix from `title` strings. Regex: `^title: "(\d+\.\d+ )(.*)"$` → `title: "$2"`. Slugs and file paths are unaffected (already kebab-case).
- Remove the `menuPre` field entirely (Lotus doesn't render it).
- Optionally add a Material Symbols `icon: "..."` field to the top-level body region `_index.md` files for sidebar icons (one icon per top-level region).
- `weight`, `description`, `tags`, `body-region` all stay as-is.

**Shortcode syntax updates inside content:**

- Relearn `{{< tabs >}}` / `{{% tab title="X" %}}` → Lotus `{{< tabs tabTotal="N" >}}` / `{{% tab tabName="X" %}}`
- Relearn `{{% notice tip %}}` / `{{% notice warning %}}` → Lotus equivalents (exact name confirmed during implementation; likely `{{% alert context="info" %}}` / `{{% alert context="warning" %}}`)

Content edits are done as scripted `sed` passes across all `.md` files, with diffs reviewed before commit. No hand-editing of individual files.

## Section 3: Body map system port

**SVG source change.** Replace the current react-body-highlighter polygon SVGs with extracted paths from `HichamELBSI/react-native-body-highlighter` (MIT, 212★). The path data lives in `assets/bodyFront.ts` and `assets/bodyBack.ts` of that repo as TypeScript path strings keyed by slug. Extraction process:

1. Pull the slug → path mapping from each `bodyFront.ts` / `bodyBack.ts`.
2. For each entry, emit `<g id="region-{slug}" class="body-region" data-region="{slug}"><path d="..." /></g>`.
3. Wrap each `<g>` in `<a href="/body-region/{slug}/" class="body-region-link">`.
4. Save as `static/svg/body-front.svg` and `static/svg/body-back.svg` with appropriate `viewBox`.
5. Verify each `region-{slug}` matches a slug in `data/body_regions.toml`.

**Files that port (with edits to remove Relearn coupling):**

| File | Change |
|---|---|
| `layouts/partials/body-map.html` | Strip Relearn CSS variable references; use plain CSS classes. Add a front/back view toggle (single button, JS one-liner toggling a class on the wrapper to swap which SVG is visible). |
| `layouts/taxonomy/body-region.html` | Replace any Relearn-specific shortcode usage with Lotus equivalents or plain Hugo `range`. |
| `layouts/taxonomy/body-region.terms.html` | Same. |
| Body map CSS | Move out of `theme-mobility.css` into a single `assets/css/body-map.css` (or inline in `body-map.html`). Vanilla CSS, no theme-variant duplication. |

**Files dropped:**

- `layouts/partials/body-map-context.html` (article-level body context — out of scope)
- `layouts/shortcodes/body-map-context.html` (shortcode wrapper for above)
- `assets/css/theme-mobility.css`, `theme-mobility-dark.css`, `chroma-mobility.css`
- All body-map-related additions inside `custom-header.html` (folded into `body-map.css`)

**Homepage mount point.** Override Lotus's `layouts/index.html` with a thin local file that wraps the body map in Lotus's `partials/landing/hero.html`. Below the body map, optionally render Lotus's `feature_grid.html` pointing at routines and concepts.

## Section 4: Theme defaults policy

**Accept as vanilla** (no overrides):

- Color palette — Lotus default. Single accent-color override available via `hugo.toml` `[params.docs] themeColor` if default clashes; not pre-emptively used.
- Typography — Lotus default fonts. No Source Serif / Inter overrides.
- Theme toggle — Lotus's binary light/dark. Three-way Light/Auto/Dark and the `variantswitcher.html` partial are dropped.
- Sidebar styling — Lotus default with optional Material Symbols icons per top-level region.
- Sidebar prefix — none (JD numbers stripped from titles).
- Syntax highlighting — Lotus default (Prism.js). `chroma-mobility.css` dropped.
- Footnotes / TOC — Lotus defaults. JD-style footnote styling and centered inline TOC overrides dropped.
- Difficulty badges — dropped. Difficulty stays as a tag, surfaced via Lotus's standard tag rendering.

**Override** (custom):

- Homepage — `layouts/index.html` mounts the body map.
- Body region taxonomy pages — `layouts/taxonomy/body-region.html` and `body-region.terms.html`.

## Section 5: Navigation layers

Six layers, anatomy-first with reinforcing context:

1. **Body map (homepage hero).** Front-view default with toggle to back view. Region-id contract matches `data/body_regions.toml`.
2. **Body region taxonomy pages** (`/body-region/<slug>/`). Region description from `body_regions.toml` plus an indexed list of all content tagged with that region, grouped by content type (exercises / routines / concepts).
3. **Lotus Docs sidebar.** Hierarchical: Lower Body / Upper Body / Spine & Core / Routines / Concepts. Built from content tree, ordered by `weight`. Material Symbols icons on top-level sections.
4. **Lotus breadcrumbs + prev/next.** Both built-in.
5. **Search — FlexSearch.** Lotus default. Pagefind dropped from this port; revisitable post-launch if FlexSearch is insufficient.
6. **Inline cross-links inside content.** Manual, opportunistic. No system-wide convention.

Explicitly **not** included:
- Custom "related exercises" widget (taxonomy pages already do this work).
- A "by difficulty" or "by modality" index page.
- Article-level body map context (Layer 5 from earlier draft — dropped).

## Section 6: Build pipeline, search, cutover

**Build pipeline.** No Node/npm dependency. Hugo Extended handles Sass via the Bootstrap module.

`Makefile`:

- `make dev` → `hugo server --buildDrafts`
- `make build` → `hugo --environment production`
- `make clean` → `rm -rf public/ resources/`

`netlify.toml` build command: `hugo --environment production`. Drops the Pagefind step entirely.

**Search.** FlexSearch via `hugo.toml`:

```toml
[params.docs]
  flexSearch = true
```

No external service, no API key. Client-side index built at site-build time. Sufficient for ~120 pages.

**Cutover sequence:**

1. Verify in worktree — local `hugo server` clean; body map renders with new SVG; all taxonomy pages, sidebar, breadcrumbs, prev/next, search functional.
2. Push `lotus-port` branch; Netlify deploy preview gives a separate URL.
3. QA on the deploy preview — homepage, one taxonomy page per body region area, sample exercises with media tabs, routines, concepts (~15 pages total). Fix shortcode-translation breakage as found.
4. Tag the last Relearn commit on `main`: `git tag relearn-final <commit>`. Safety net for rollback.
5. Merge `lotus-port` into `main`. Netlify production picks up the change. No DNS change needed (same site URL).
6. Post-launch — Netlify deploy logs, manual click-through, internal-link checker. Issues become follow-up commits on `main`, not rollbacks.

## Decisions / rationale

- **Approach A (worktree, side-by-side rebuild)** chosen over in-place theme swap because the current site stays live and an A/B comparison is easier with two trees.
- **react-native-body-highlighter** chosen as new SVG source because it's MIT-licensed (212★, well-maintained) and the path data is straightforwardly extractable. `MuscleMapAssetPack` was visually superior but unlicensed; left as a future option contingent on the author adding a license.
- **FlexSearch over Pagefind** — Lotus's default is sufficient for ~120 pages; reverting to Pagefind is a one-step Netlify config change post-launch if needed.
- **Front/back toggle over side-by-side** — simpler layout, no horizontal squeeze on mobile, single body map at a time keeps focus.
- **Article-level body map context dropped** — body region taxonomy pages already provide the "where on my body" context; per-article repetition adds noise without adding navigation value.
- **Difficulty badges dropped** — were a custom Relearn-era addition, not load-bearing for navigation. Tag-based difficulty surfacing remains. Easy to re-add later if desired.
- **JD numbering stripped from titles** — drops a custom design layer for cleaner sidebar labels in vanilla Lotus.

## Open questions for implementation

- Exact Lotus `notice` / `alert` shortcode name (`{{% alert context="..." %}}` is likely but should be confirmed by reading Lotus partials during implementation).
- Whether to put the front/back toggle inside the SVG wrapper (CSS-only `.is-back` class swap) or as a separate JS button — CSS-only is simpler and works without JS.
- Final accent-color decision — leave Lotus default first, override only if it clashes with the body map's hover color.

## Success criteria

- Local `hugo server` renders the new site with no Relearn-era files present.
- All 120-ish content pages reachable via sidebar.
- Body map on homepage renders cleanly, region clicks navigate to taxonomy pages.
- Front/back toggle works.
- Each body region taxonomy page lists tagged content correctly.
- Lotus breadcrumbs and prev/next visible on every exercise page.
- FlexSearch returns relevant hits for representative queries (e.g. "hip flexor", "thoracic mobility").
- Netlify deploy preview matches local; production cutover via merge produces no broken links.
