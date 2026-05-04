# Lotus Docs Port — Session Handoff

**Last session:** 2026-05-03
**Branch:** `lotus-port` (worktree at `../24-mobility-lotusdocs/`, local only — not pushed)
**Latest commit:** `921b836` — Homepage density: three-column with map in the middle
**Production status:** Unaffected. `mobility-guide.netlify.app` still deploys from `main` / Relearn.

---

## What this is

A side-by-side rebuild porting the badwater.guide mobility site from Hugo Relearn to Hugo Lotus Docs. The current Relearn site keeps deploying from `main`; this worktree on the `lotus-port` branch holds the Lotus replacement until cutover.

**Spec:** [docs/superpowers/specs/2026-05-03-lotus-docs-port-design.md](docs/superpowers/specs/2026-05-03-lotus-docs-port-design.md)
**Plan:** [docs/superpowers/plans/2026-05-03-lotus-docs-port.md](docs/superpowers/plans/2026-05-03-lotus-docs-port.md)
**SVG slug mapping spike:** [docs/superpowers/specs/2026-05-03-body-map-slug-mapping.md](docs/superpowers/specs/2026-05-03-body-map-slug-mapping.md)

---

## What's done

### Phase 1–6 of the plan (Tasks 1–19 + 8.5)
- Hugo Module install of Lotus Docs + Bootstrap-SCSS (no submodule).
- Content migration: `menuPre` stripped from 148 files, tabs shortcode rewritten across 135 files, notice→alert across 129 files.
- Body map system rebuilt with paths from `HichamELBSI/react-native-body-highlighter` (MIT). Front + back SVGs include head/hair/hands as decoration; previously synthesized hips polygon was removed because it disrupted the front anatomy.
- Body region taxonomy layouts (`layouts/body-region/term.html` and `terms.html`) ported.
- `exercise-table` shortcode simplified (drop the JD `#` column).
- `_default/{baseof,list,single}.html` overrides so content outside `content/docs/` gets Lotus's docs treatment (sidebar, breadcrumbs, TOC, prev/next).
- Build pipeline: Makefile and netlify.toml updated. Pagefind dropped (Lotus FlexSearch suffices). All six `[[headers]]` in netlify.toml preserved.

### Visual review polish
- JD prefixes stripped from markdown bodies (33 instances across 6 `_index.md` files).
- Custom `head.html` override removed — was breaking Lotus's SCSS pipeline. Body-map CSS now inlines via Hugo resource pipeline inside `body-map.html`.
- Body region fill strengthened from washed-out gray to solid `#3f3f3f` at 0.85 opacity.

### Homepage redesign — Option C (quickstart-first)
- Hero (single H1 from baseof) + tagline ("Move better. Recover faster.").
- Quickstart band with 7 pills linking to real content (Pre-shift, Post-shift, Tight hips, Sore back, Knee pain, Sore shoulders, Stiff neck).
- Three-column dense layout below the band:
  - **Sections** — live counts from `site.RegularPages` by section.
  - **Body Map** (middle) — 240px figure with front/back toggle.
  - **Body Regions** — 2-col grid sorted by `.Site.Taxonomies.body-region` count.
- Concepts strip below the columns.

### Visual identity
- **Badwater "Playa & Ink" palette** applied site-wide, sourced from the `33.02 Badwater Hugo` site.
  - Light: Badwater Salt `#EFEAE0`, Basalt `#2B2A28`, Badwater Red `#B43E2E`, Rabbitbrush Gold `#C7A955`.
  - Dark: Obsidian `#161618`, Moonlit Salt `#EBE6D9`, Highlight Coral `#E47A60`, Rabbitbrush Ember `#D4B464`.
  - Both `prefers-color-scheme` and explicit `[data-bs-theme]` are handled.
  - Loaded via `assets/css/badwater-palette.css` in `_default/baseof.html` after Lotus's stylesheet.
- **Quickstart chip styles** — Option B light (outlined chips, gold leader), Option D dark (filled terracotta pills, gold leader).

---

## What's still open

### 1. Typography
Lotus default fonts are still in use. Next obvious move: **Source Serif 4 body + Inter UI**, both available via Lotus's `googleFonts` param. To wire up:

```toml
# In hugo.toml under [params]
[[params.google_fonts]]
  name = "Inter"
  sizes = [400, 500, 600, 700]
[[params.google_fonts]]
  name = "Source Serif 4"
  sizes = [400, 600]

# Then in [params]
secondary_font = "'Source Serif 4', ui-serif, Georgia, serif"
sans_serif_font = "'Inter', system-ui, -apple-system, sans-serif"
```

Verify it picks up by inspecting the site's compiled CSS for the Sass variables. Lotus's `style.scss` reads these params at build time.

### 2. Homepage polish (low-priority)
- Column proportions on the three-col layout — the body map column may want more or less width.
- Hover states could push more (subtle background shift on section list rows).
- Optional adds we discussed but didn't build: featured routine of the day, recent additions, tags row.

### 3. Cutover (Tasks 21–25 of the plan)
Once the homepage feels finished:

- **Task 21:** Push `lotus-port` branch to GitHub. Netlify auto-creates a deploy preview at a separate URL.
- **Task 22:** Tag the last Relearn commit on `main` as `relearn-final` (rollback safety net).
- **Task 23:** Merge `lotus-port` into `main`. Production switches to Lotus Docs.
- **Task 24:** Worktree cleanup — `git worktree remove ../24-mobility-lotusdocs`.
- **Task 25:** Post-launch monitoring — Netlify deploy logs, manual click-through, internal-link checker.

The plan document has detailed steps with rollback rehearsal commands.

---

## How to resume

### Start the dev server
```bash
cd "/Users/dom/Documents/Claude/Projects/20-29 DMIHC Projects/24-mobility-lotusdocs"
hugo server -p 8081 --buildDrafts --disableFastRender
```

Or via the `hugo-lotus` config in `.claude/launch.json` (parent project). Site at `http://localhost:8081/`.

### Verify state
```bash
git status              # should be clean
git log -3 --oneline    # confirm latest commit is 921b836 (or later if you've added)
git worktree list       # both worktrees present
```

---

## Key files

| File | Responsibility |
|---|---|
| `hugo.toml` | Module imports, taxonomy, Lotus params. Backup at `hugo.toml.relearn-backup`. |
| `layouts/index.html` | Homepage — Option C with three-column dense layout. Inline `<style>` for `.bw-home`. |
| `layouts/_default/baseof.html` | Site-wide layout (copy of Lotus's `docs/baseof.html` — gives every section the docs chrome). Loads `badwater-palette.css` after Lotus's stylesheet. |
| `layouts/_default/list.html` | Section list pages — wraps `.Content` over Lotus's docs card grid. |
| `layouts/_default/single.html` | Single-page leaves — minimal, just wraps `.Content`. |
| `layouts/body-region/{term,terms}.html` | Body region taxonomy layouts (vanilla Hugo, no Relearn shortcodes). |
| `layouts/partials/body-map.html` | Body map partial; inlines body-map.css via Hugo resource pipeline. |
| `layouts/shortcodes/exercise-table.html` | Simplified exercise table (Exercise / Focus columns). |
| `assets/css/body-map.css` | Body map styling — vanilla CSS, both modes. |
| `assets/css/badwater-palette.css` | Site-wide Bootstrap CSS-variable overrides for Playa & Ink palette (light + dark via media query and explicit attribute). |
| `static/svg/{body-front,body-back}.svg` | New SVGs from react-native-body-highlighter (MIT) with decorative head/hair/hands and 8 clickable region groups per view. |
| `data/body_regions.toml` | Region slug → label/description/views mapping. |

---

## Known issues / decisions

- **`hips` has no front-view click region.** Source library has no hips path; we initially synthesized one but it visually disrupted the front figure. Hips is reachable via the Body Regions card in the homepage three-col layout, the sidebar, and the URL `/body-region/hips/`. Not via the front body figure itself.
- **Custom `head.html` is no longer overridden.** An earlier attempt broke Lotus's Sass pipeline. Body-map CSS now inlines via the partial. If we ever need site-wide CSS injection in `<head>`, we'd need to find a different mechanism (overriding `head.html` cleanly is hard without re-implementing Lotus's full head logic).
- **Two `prefers-color-scheme` pathways are wired:** the badwater palette uses both `@media (prefers-color-scheme: dark)` and `[data-bs-theme="dark"]` because Lotus's theme toggle uses the attribute, but the OS preference uses the media query. Both must be handled or modes break.
- **`_index.md` title was renamed** from "Mobility, Recovery & Strength Exercise Library" to "Badwater Mobility" with `linktitle: "Home"`, since the docs/baseof.html renders the page title automatically (was duplicating with my hero h1).

---

## Resume points by goal

**If you want to refine the homepage:** open `layouts/index.html` — most styling is in the inline `<style>` block at the top. Three-col grid is `.three-col` at line ~150ish.

**If you want to set fonts:** edit `hugo.toml` per the snippet in section 1 above. No layout changes needed.

**If you want to push to Netlify deploy preview:** `git push -u origin lotus-port` then watch the Netlify dashboard for the preview URL.

**If you want to do the full cutover:** read Tasks 21–25 in the plan, then do them in order.
