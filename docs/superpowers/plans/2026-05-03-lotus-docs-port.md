# Lotus Docs Port — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Hugo Relearn theme on the badwater.guide mobility site with Hugo Lotus Docs, in a side-by-side worktree, while upgrading the body map SVG to a higher-quality MIT-licensed source.

**Architecture:** A `git worktree` off `main` (at `../24-mobility-lotusdocs/`) hosts a clean rebuild. Hugo Module installs Lotus Docs (no submodule). Content, data, and static assets port wholesale. The body map system ports with a new SVG source. Relearn-era custom CSS, theme variants, and partials are dropped. Cutover happens by merging the `lotus-port` branch into `main`.

**Tech Stack:** Hugo Extended (≥0.157), Hugo Modules (Go), Lotus Docs theme, Bootstrap 5 + Sass, Material Symbols, FlexSearch (Lotus default), Netlify.

**Spec reference:** [docs/superpowers/specs/2026-05-03-lotus-docs-port-design.md](../specs/2026-05-03-lotus-docs-port-design.md)

---

## Notation

This is a Hugo static site port — most "tests" are render checks, not unit tests. Verification commands are embedded at the end of each task. Treat them as TDD analogs: if `hugo server` errors or the expected page doesn't render correctly, the task isn't done.

Working directory abbreviations:
- **CURRENT** = `/Users/dom/Documents/Claude/Projects/20-29 DMIHC Projects/24 mobility website development/` (the existing Relearn site, on branch `main`)
- **WORKTREE** = `/Users/dom/Documents/Claude/Projects/20-29 DMIHC Projects/24 mobility website development/../24-mobility-lotusdocs/` (the new Lotus Docs site, on branch `lotus-port`)

Most commands run inside WORKTREE unless otherwise noted.

---

## File Structure

**Created in WORKTREE:**

| Path | Responsibility |
|---|---|
| `hugo.toml` | Hugo config: site params, Lotus Docs params, module imports, taxonomy declaration |
| `go.mod` | Hugo Module manifest |
| `go.sum` | Module checksum |
| `layouts/index.html` | Homepage override mounting the body map |
| `layouts/partials/body-map.html` | Body map partial (vanilla CSS, front/back toggle) |
| `layouts/body-region/term.html` | Single-term taxonomy page (per-region content listing) |
| `layouts/body-region/terms.html` | Terms-list taxonomy page |
| `layouts/shortcodes/exercise-table.html` | Simplified exercise table (Exercise / Focus columns only) |
| `assets/css/body-map.css` | Vanilla CSS for body map hover, active, and toggle states |
| `static/svg/body-front.svg` | New body map front view (extracted from react-native-body-highlighter) |
| `static/svg/body-back.svg` | New body map back view |
| `Makefile` | `dev`, `build`, `clean` targets |
| `netlify.toml` | Build command + publish dir |

**Migrated wholesale into WORKTREE:**

| Path | Source |
|---|---|
| `content/` | Copied from CURRENT, then `menuPre` field stripped + shortcode syntax updated |
| `data/body_regions.toml` | Copied from CURRENT, unchanged |
| `archetypes/default.md` | Copied from CURRENT |
| `static/` (minus `static/svg/`) | Copied from CURRENT |

**Not present in WORKTREE** (Relearn-era, dropped):

`themes/`, `assets/css/theme-mobility*.css`, `assets/css/chroma-mobility.css`, `layouts/_default/`, `layouts/sidebar/`, `layouts/home/`, `layouts/partials/custom-header.html`, `layouts/partials/content-header.html`, `layouts/partials/menu-footer.html`, `layouts/partials/custom-footer.html`, `layouts/partials/body-map-context.html`, `layouts/shortcodes/body-map-context.html`, the previous `static/svg/body-front.svg` and `static/svg/body-back.svg`.

---

## Phase 1: Pre-implementation spike

The spec calls out one high-uncertainty piece — mapping the new SVG source's slug list to our 14 region slugs. Resolve it before committing to the full port.

### Task 1: SVG slug-mapping spike

**Files:**
- Read: `data/body_regions.toml` (CURRENT)
- Read: source paths from `https://raw.githubusercontent.com/HichamELBSI/react-native-body-highlighter/main/assets/bodyFront.ts` and `bodyBack.ts`

- [ ] **Step 1: Pull the source TS files**

```bash
mkdir -p /tmp/body-map-spike
curl -s https://raw.githubusercontent.com/HichamELBSI/react-native-body-highlighter/main/assets/bodyFront.ts > /tmp/body-map-spike/bodyFront.ts
curl -s https://raw.githubusercontent.com/HichamELBSI/react-native-body-highlighter/main/assets/bodyBack.ts > /tmp/body-map-spike/bodyBack.ts
```

- [ ] **Step 2: Extract slug list from each file**

```bash
grep -oE 'slug: "[^"]+"' /tmp/body-map-spike/bodyFront.ts | sort -u > /tmp/body-map-spike/front-slugs.txt
grep -oE 'slug: "[^"]+"' /tmp/body-map-spike/bodyBack.ts | sort -u > /tmp/body-map-spike/back-slugs.txt
cat /tmp/body-map-spike/front-slugs.txt /tmp/body-map-spike/back-slugs.txt
```

Expected: ~25 unique slugs each (chest, biceps, triceps, deltoids, abs, obliques, quads, hamstrings, calves, glutes, traps, lats, etc.)

- [ ] **Step 3: List our 14 target region slugs**

Read CURRENT/data/body_regions.toml. Our slugs are: `neck`, `shoulders`, `chest`, `arms`, `core`, `hips`, `quads`, `ankles`, `upper-back`, `lower-back`, `glutes`, `hamstrings`, `calves`, `feet`.

- [ ] **Step 4: Build the slug map**

For each of our 14 slugs, write down which source slug(s) compose it. Document this map at `docs/superpowers/specs/2026-05-03-body-map-slug-mapping.md` (in CURRENT, on `main`). The worktree doesn't exist yet at this stage. Sample mapping:

| Our slug | Source slug(s) | View(s) |
|---|---|---|
| neck | neck | front + back |
| shoulders | front-deltoids, back-deltoids (or "deltoids") | front + back |
| chest | chest | front |
| arms | biceps, triceps, forearms | front + back |
| core | abs, obliques | front |
| hips | hips, abductors, adductors (if present) | front |
| quads | quads | front |
| ankles | ankles (or synthesized region near calves) | front + back |
| upper-back | trapezius, upper-back | back |
| lower-back | lower-back | back |
| glutes | gluteal | back |
| hamstrings | hamstring | back |
| calves | calves | back |
| feet | feet (if present, else synthesize) | front + back |

- [ ] **Step 5: Identify gaps**

If any of our 14 slugs has no source path (e.g. "feet" might not exist as a distinct path), decide for that slug: synthesize a small polygon over the appropriate region, or remove from `body_regions.toml`. Note decisions in the slug-mapping doc.

- [ ] **Step 6: Sanity-extract one region**

Pull one path from `bodyFront.ts` (e.g. the chest path for one side). Wrap it in a minimal test SVG. Open in a browser. Confirm it renders as a recognizable chest shape.

```bash
# Manual: copy one path string into a test.svg, view in browser
```

- [ ] **Step 7: Commit the mapping doc**

This task produces only documentation — no code change in the WORKTREE yet (the WORKTREE doesn't exist). Commit the mapping doc to CURRENT under the spec's docs folder so future tasks reference it.

```bash
cd "/Users/dom/Documents/Claude/Projects/20-29 DMIHC Projects/24 mobility website development"
mkdir -p docs/superpowers/specs
# write docs/superpowers/specs/2026-05-03-body-map-slug-mapping.md
git add docs/superpowers/specs/2026-05-03-body-map-slug-mapping.md
git commit -m "Add body map slug mapping for Lotus Docs port"
```

**Done when:** Every entry in `data/body_regions.toml` has a documented source slug or a documented decision to synthesize/remove.

---

## Phase 2: Worktree creation and Lotus Docs install

### Task 2: Create the lotus-port worktree

**Files:**
- Create: WORKTREE (entire directory)

- [ ] **Step 1: Verify CURRENT is on a clean main**

```bash
cd "/Users/dom/Documents/Claude/Projects/20-29 DMIHC Projects/24 mobility website development"
git status
git branch --show-current
```

Expected: `main`, working tree clean.

- [ ] **Step 2: Create the worktree**

```bash
git worktree add -b lotus-port ../24-mobility-lotusdocs main
cd ../24-mobility-lotusdocs
git status
```

Expected: branch `lotus-port`, identical to `main` snapshot.

- [ ] **Step 3: Commit empty marker so worktree has its own first commit**

```bash
echo "Lotus Docs port — clean rebuild in progress" > PORT_IN_PROGRESS.txt
git add PORT_IN_PROGRESS.txt
git commit -m "Begin Lotus Docs port"
```

**Done when:** WORKTREE exists at `../24-mobility-lotusdocs/`, branch `lotus-port` checked out, one commit ahead of `main`.

---

### Task 3: Strip Relearn-era files from worktree

**Files:**
- Delete (in WORKTREE): theme files, custom layouts, Relearn-era CSS, old SVGs

- [ ] **Step 1: Remove the Relearn theme submodule**

```bash
cd "/Users/dom/Documents/Claude/Projects/20-29 DMIHC Projects/24 mobility website development/../24-mobility-lotusdocs"
git rm -rf themes/ 2>/dev/null || rm -rf themes/
rm -f .gitmodules
```

- [ ] **Step 2: Remove Relearn-era CSS**

```bash
rm -f assets/css/theme-mobility.css assets/css/theme-mobility-dark.css assets/css/chroma-mobility.css
# Keep assets/ directory itself; we'll add body-map.css later
```

- [ ] **Step 3: Remove Relearn-era layouts**

```bash
rm -rf layouts/_default/
rm -rf layouts/sidebar/
rm -rf layouts/home/
rm -f layouts/partials/custom-header.html
rm -f layouts/partials/content-header.html
rm -f layouts/partials/menu-footer.html
rm -f layouts/partials/custom-footer.html
rm -f layouts/partials/body-map-context.html
rm -f layouts/shortcodes/body-map-context.html
```

- [ ] **Step 4: Remove old body map SVGs (will be replaced)**

```bash
rm -f static/svg/body-front.svg static/svg/body-back.svg
```

- [ ] **Step 5: Verify what remains**

```bash
ls layouts/
ls layouts/partials/ 2>/dev/null
ls layouts/shortcodes/ 2>/dev/null
ls assets/css/ 2>/dev/null
ls static/svg/ 2>/dev/null
```

Expected: `layouts/body-region/` (term.html, terms.html — survives, will be edited later), `layouts/partials/body-map.html` (survives, will be edited), `layouts/shortcodes/exercise-table.html` (survives, will be edited). `assets/css/` empty. `static/svg/` empty.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "Remove Relearn-era theme files, custom CSS, and old body map SVGs"
```

**Done when:** Worktree contains content, data, archetypes, the body-region taxonomy layouts, the body-map.html partial, the exercise-table shortcode, and not much else.

---

### Task 4: Initialize Hugo Module + add Lotus Docs

**Files:**
- Create: `go.mod`, `go.sum` (auto-generated)
- Modify: `hugo.toml`

- [ ] **Step 1: Verify Hugo Extended >= 0.157**

```bash
hugo version
```

Expected: output includes `extended` and version >= `v0.157.0`. Lotus Docs requires Hugo Extended.

- [ ] **Step 2: Backup the existing hugo.toml**

```bash
cp hugo.toml hugo.toml.relearn-backup
```

- [ ] **Step 3: Initialize Hugo Module**

```bash
hugo mod init github.com/domalhambra/recovery-mobility-guide
```

Expected: `go.mod` file created.

- [ ] **Step 4: Replace hugo.toml with a Lotus Docs config**

Preserve the `[outputs]`, `[markup]`, `[sitemap]`, `[taxonomies]` blocks from the original. Drop the `[[params.themeVariant]]` blocks (Relearn-specific) and the `[[menus.shortcuts]]` block (Lotus's sidebar handles "Body Regions" via taxonomy nav, no separate shortcut needed). Drop the Relearn `[params]` keys.

```toml
baseURL = "https://mobility-guide.netlify.app/"
languageCode = "en-us"
title = "Badwater Mobility"

# Hugo Modules
[module]
  [[module.imports]]
    path = "github.com/colinwilson/lotusdocs"
  [[module.imports]]
    path = "github.com/gohugoio/hugo-mod-bootstrap-scss/v5"

# Outputs (preserved from current site)
[outputs]
  home = ["HTML", "RSS"]

# Markup (preserved from current site)
[markup]
  [markup.goldmark]
    [markup.goldmark.renderer]
      unsafe = true
  [markup.tableOfContents]
    startLevel = 2
    endLevel = 3

# Sitemap (preserved from current site)
[sitemap]
  changefreq = "weekly"
  priority = 0.5

# Taxonomies (preserved from current site)
[taxonomies]
  tag = "tags"
  body-region = "body-region"

# Lotus Docs site params (minimal — defaults preferred)
[params]
  description = "Practical mobility and recovery for wildland firefighters."
  # google_fonts intentionally not set — use Lotus defaults
  # themeColor intentionally not set — add only if Lotus default clashes with body map hover

  [params.docs]
    title = "Badwater Mobility"
    description = "Practical mobility and recovery for wildland firefighters."
    flexSearch = true
    sidebarIcons = true
    darkMode = true
    breadcrumbs = true
    backToTop = true
    titleIcon = "accessibility_new"
```

- [ ] **Step 5: Pull Lotus Docs module**

```bash
hugo mod get github.com/colinwilson/lotusdocs
hugo mod get github.com/gohugoio/hugo-mod-bootstrap-scss/v5
```

Expected: `go.sum` updated with module checksums.

- [ ] **Step 6: Verify Hugo can start**

```bash
hugo server --buildDrafts --disableFastRender 2>&1 | head -30
```

Expected: Hugo and Lotus Docs theme load without theme-loading errors. Shortcode errors on individual pages are expected at this stage (135 files use unmigrated `tabs`, 129 use unmigrated `notice`, six pages reference `menuPre` via `exercise-table`). Theme-loading or template-resolution errors are NOT expected — if you see those, debug before continuing. Stop the server (Ctrl-C).

- [ ] **Step 7: Commit**

```bash
git add hugo.toml hugo.toml.relearn-backup go.mod go.sum
git commit -m "Initialize Hugo Module with Lotus Docs theme"
```

**Done when:** `hugo mod graph` shows `github.com/colinwilson/lotusdocs` as a dependency, and `hugo server` starts without theme-loading errors.

---

## Phase 3: Content migration

### Task 5: Strip `menuPre` from all content files

**Files:**
- Modify: every `.md` file in `content/`

- [ ] **Step 1: Find all files containing menuPre**

```bash
grep -rl "^menuPre:" content/ | wc -l
```

Note the count for verification.

- [ ] **Step 2: Dry-run the strip with diff preview**

```bash
grep -rl "^menuPre:" content/ | head -3 | while read f; do
  echo "=== $f ==="
  diff <(cat "$f") <(sed '/^menuPre:/d' "$f")
done
```

Expected: clean removal of the `menuPre` line, nothing else changed.

- [ ] **Step 3: Apply the strip across all content files**

```bash
grep -rl "^menuPre:" content/ | xargs sed -i '' '/^menuPre:/d'
```

Note: `sed -i ''` is the macOS-compatible form; on Linux use `sed -i`.

- [ ] **Step 4: Verify zero remaining menuPre fields**

```bash
grep -rl "^menuPre:" content/ | wc -l
```

Expected: `0`

- [ ] **Step 5: Commit**

```bash
git add content/
git commit -m "Drop menuPre field from all content files"
```

**Done when:** Zero matches for `^menuPre:` across `content/`.

---

### Task 6: Update `tabs` and `tab` shortcode syntax

The current site uses Relearn's `{{< tabs >}}{{% tab title="X" %}}` syntax. Lotus Docs uses `{{< tabs tabTotal="N" >}}{{% tab tabName="X" %}}`. **135 files** use this shortcode.

**Files:**
- Modify: every `.md` file in `content/` that uses tabs shortcodes (135 files)

- [ ] **Step 1: Find files using the tabs shortcode**

```bash
grep -rl "{{< tabs" content/ | tee /tmp/tabs-files.txt | wc -l
```

Expected: `135`.

- [ ] **Step 2: Inspect a sample to confirm pattern**

```bash
head -1 /tmp/tabs-files.txt | xargs grep -A2 "{{< tabs"
```

Confirm format is `{{< tabs >}}` (no params) and `{{% tab title="..." %}}`.

- [ ] **Step 3: Look up Lotus Docs tabs shortcode signature**

```bash
hugo mod download github.com/colinwilson/lotusdocs 2>/dev/null
find ~/.cache/hugo_cache -name "tabs.html" -path "*lotusdocs*" -path "*shortcodes*" 2>/dev/null | head -1 | xargs head -30
```

Expected signature: `{{< tabs tabTotal="N" >}}{{% tab tabName="..." %}}...{{% /tab %}}{{< /tabs >}}`.

- [ ] **Step 4: Convert `title=` to `tabName=` inside tab tags**

```bash
xargs -I{} sed -i '' 's/{{% tab title=/{{% tab tabName=/g' < /tmp/tabs-files.txt
```

- [ ] **Step 5: Script the `tabTotal` injection**

Per the spec, this is a scripted pass — not per-file hand-editing. Write a Python helper at `/tmp/add-tab-total.py`:

```python
import re, sys

def patch(text: str) -> str:
    # Match a {{< tabs >}} ... {{< /tabs >}} block; count {{% tab tabName= openers inside.
    pattern = re.compile(r'(\{\{<\s*tabs\s*>\}\})(.*?)(\{\{<\s*/tabs\s*>\}\})', re.DOTALL)
    def repl(m):
        opener, body, closer = m.group(1), m.group(2), m.group(3)
        n = len(re.findall(r'\{\{%\s*tab\s+tabName=', body))
        if n == 0:
            return m.group(0)  # leave alone if no tabs found inside
        new_opener = f'{{{{< tabs tabTotal="{n}" >}}}}'
        return new_opener + body + closer
    return pattern.sub(repl, text)

for path in sys.argv[1:]:
    with open(path, 'r') as f:
        original = f.read()
    new = patch(original)
    if new != original:
        with open(path, 'w') as f:
            f.write(new)
        print(f"updated: {path}")
```

Run it across the 135 files:

```bash
xargs python3 /tmp/add-tab-total.py < /tmp/tabs-files.txt | wc -l
```

Expected: ~135 files updated.

- [ ] **Step 6: Verify no `{{< tabs >}}` (no params) remain**

```bash
grep -rE "\{\{<\s*tabs\s*>\}\}" content/ | wc -l
```

Expected: `0` (every tabs block now has `tabTotal`).

- [ ] **Step 7: Spot-check a sample**

```bash
head -1 /tmp/tabs-files.txt | xargs grep "{{< tabs"
```

Expected: `{{< tabs tabTotal="N" >}}` for some integer N.

- [ ] **Step 8: Commit**

```bash
git add content/
git commit -m "Convert tabs shortcode syntax from Relearn to Lotus Docs (135 files)"
```

**Done when:** Every `tabs` block in content has `tabTotal="N"` set, and every nested `tab` uses `tabName=` instead of `title=`.

---

### Task 7: Update `notice` shortcode syntax

**Files:**
- Modify: every `.md` file using the Relearn `notice` shortcode (129 files)

- [ ] **Step 1: Find files using `notice`**

```bash
grep -rl "{{% notice" content/ | tee /tmp/notice-files.txt | wc -l
```

Expected: `129`.

- [ ] **Step 2: Look up Lotus Docs equivalent**

Check Lotus Docs's example site or shortcodes folder for the notice/alert shortcode name. Likely `alert` with a `context` parameter:

```
{{% alert context="info" %}} ... {{% /alert %}}
```

- [ ] **Step 3: Convert each variant**

```bash
xargs -I{} sed -i '' \
  -e 's/{{% notice tip %}}/{{% alert context="info" %}}/g' \
  -e 's/{{% notice warning %}}/{{% alert context="warning" %}}/g' \
  -e 's/{{% notice note %}}/{{% alert context="info" %}}/g' \
  -e 's/{{% \/notice %}}/{{% \/alert %}}/g' \
  < /tmp/notice-files.txt
```

Adjust mapping based on the actual variants found in step 1 (`grep -roE "{{% notice [a-z]+" content/ | sort -u`).

- [ ] **Step 4: Verify no `notice` shortcodes remain**

```bash
grep -rl "{{% notice" content/ | wc -l
```

Expected: `0`

- [ ] **Step 5: Commit**

```bash
git add content/
git commit -m "Convert notice shortcode to Lotus Docs alert"
```

**Done when:** No `{{% notice ... %}}` shortcodes remain in `content/`.

---

### Task 8: Verify content renders with default Lotus layouts

**Files:** None modified.

- [ ] **Step 1: Start dev server**

```bash
hugo server --buildDrafts --disableFastRender
```

- [ ] **Step 2: Sanity-click a representative tree of pages**

In a browser at `http://localhost:1313/`:
- Homepage (will look bare — no body map yet, expected)
- `/mobility/lower-body/` index — should list children
- One exercise page with tabs — verify Media tab renders, no shortcode error
- One page with the `notice` → `alert` conversion (if any) — verify the alert renders
- A `_index.md` page that uses `exercise-table` — will show a Hugo error since the shortcode references `menuPre` which no longer exists. Expected; fixed in Task 13.

- [ ] **Step 3: Stop server and note what's broken**

Write down anything broken that isn't expected (the body map, exercise-table, and homepage ARE expected to be broken at this stage). Anything else broken means content migration introduced an unintended issue.

- [ ] **Step 4: Commit no changes (this is a verification-only task)**

**Done when:** Content renders under Lotus's default layouts, with only the expected broken pieces (body map, exercise-table, homepage placeholder).

---

## Phase 4: Body map system port

### Task 9: Extract paths from react-native-body-highlighter

**Files:**
- Read: `/tmp/body-map-spike/bodyFront.ts`, `/tmp/body-map-spike/bodyBack.ts` (already pulled in Task 1)
- Read: `docs/superpowers/specs/2026-05-03-body-map-slug-mapping.md` (the mapping doc from Task 1)

- [ ] **Step 1: Inspect actual source structure first**

Read the head of `/tmp/body-map-spike/bodyFront.ts`:

```bash
head -40 /tmp/body-map-spike/bodyFront.ts
```

Confirm the actual shape of each entry. The expected structure is roughly:

```typescript
{
  slug: "chest",
  color: "#3f3f3f",
  path: {
    left: [ "M272.91 422.84c..." ],
    right: [ "M416.04 435c..." ],
  },
},
```

Adjust the extractor below if the structure differs.

- [ ] **Step 2: Write a robust extraction script**

The naive regex approach fails on nested braces and array-bracket structure. Use a small token-aware parser. `/tmp/body-map-spike/extract.py`:

```python
import re, sys, json

def parse_ts(path):
    text = open(path).read()
    out = {}
    # Find each block opener: "{ slug: "X","
    for m in re.finditer(r'\{\s*slug:\s*"([^"]+)"', text):
        slug = m.group(1)
        # From the slug match, walk forward, tracking brace depth, to find the matching closing "}"
        i = m.end()
        depth = 1  # we're inside one open brace already (the entry's outer brace)
        while i < len(text) and depth > 0:
            c = text[i]
            if c == '{': depth += 1
            elif c == '}': depth -= 1
            i += 1
        block = text[m.start():i]
        # Within this block, find left and right path arrays
        left = []
        right = []
        # Match `left: [ "..." , "..." ]` — capture all M-prefixed strings
        left_match = re.search(r'left:\s*\[(.*?)\]', block, re.DOTALL)
        if left_match:
            left = re.findall(r'"(M[^"]+)"', left_match.group(1))
        right_match = re.search(r'right:\s*\[(.*?)\]', block, re.DOTALL)
        if right_match:
            right = re.findall(r'"(M[^"]+)"', right_match.group(1))
        out[slug] = {"left": left, "right": right}
    return out

front = parse_ts('/tmp/body-map-spike/bodyFront.ts')
back = parse_ts('/tmp/body-map-spike/bodyBack.ts')
print(json.dumps({"front": front, "back": back}, indent=2))
```

- [ ] **Step 3: Run extraction**

```bash
python3 /tmp/body-map-spike/extract.py > /tmp/body-map-spike/paths.json
```

- [ ] **Step 4: Sanity check**

```bash
jq 'keys' /tmp/body-map-spike/paths.json
jq '.front | keys' /tmp/body-map-spike/paths.json
jq '.front.chest' /tmp/body-map-spike/paths.json
```

Expected: keys include `back` and `front`; each has slugs with non-empty `left` and/or `right` arrays. If any expected slug is missing or has empty arrays, fix the extractor before continuing — the rest of the body map work depends on this data.

**Done when:** `paths.json` contains non-empty path arrays for every slug referenced in the slug-mapping doc.

---

### Task 10: Build `static/svg/body-front.svg`

**Files:**
- Create: `static/svg/body-front.svg`

- [ ] **Step 1: Determine the source viewBox**

Look at the source `bodyFront.ts` for any size hints — usually the React Native component sets a `width` and `viewBox` in its wrapper. Check `components/SvgMaleWrapper.tsx`:

```bash
grep -E "width|viewBox" /tmp/body-map-spike/SvgMaleWrapper.tsx 2>/dev/null || \
  curl -s https://raw.githubusercontent.com/HichamELBSI/react-native-body-highlighter/main/components/SvgMaleWrapper.tsx | grep -E "width|viewBox"
```

Expected: a viewBox like `0 0 720 1280` or similar. Record this for use in the SVG.

- [ ] **Step 2: Generate the SVG using the slug mapping**

Write `static/svg/body-front.svg` programmatically. For each of our 14 region slugs that has front-view paths per the mapping doc, emit:

```html
<a href="/body-region/{our-slug}/" class="body-region-link">
  <g id="region-{our-slug}" class="body-region" data-region="{our-slug}">
    <!-- Combined paths from one or more source slugs -->
    <path d="..." />
    <path d="..." />
  </g>
</a>
```

Wrapped in:

```html
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 720 1280" class="body-map-svg body-map-front">
  <!-- Front view — paths from HichamELBSI/react-native-body-highlighter (MIT) -->
  ...
</svg>
```

This is most easily done by hand-editing once, using the `paths.json` data as input. Generate a Python script that emits the SVG if you prefer to keep it reproducible.

- [ ] **Step 3: Open the SVG in a browser**

```bash
open static/svg/body-front.svg
```

Expected: a recognizable human figure (front view), with all 14 regions visible.

- [ ] **Step 4: Visual QA — verify each region**

Use a temporary CSS rule (apply via browser dev tools) to color each region a distinct color. Confirm regions are roughly where they should be.

- [ ] **Step 5: Commit**

```bash
git add static/svg/body-front.svg
git commit -m "Add new body-front.svg from react-native-body-highlighter (MIT)"
```

**Done when:** The SVG renders a clean front-view human figure with 14 named, link-wrapped region groups.

---

### Task 11: Build `static/svg/body-back.svg`

**Files:**
- Create: `static/svg/body-back.svg`

- [ ] **Step 1: Generate the back-view SVG**

Same procedure as Task 10, using back-view paths from `paths.json`. Use the same viewBox.

- [ ] **Step 2: Visual QA**

```bash
open static/svg/body-back.svg
```

Expected: recognizable back-view figure.

- [ ] **Step 3: Commit**

```bash
git add static/svg/body-back.svg
git commit -m "Add new body-back.svg from react-native-body-highlighter (MIT)"
```

**Done when:** Back-view SVG renders correctly with regions matching the slug mapping.

---

### Task 12: Port `layouts/partials/body-map.html`

**Files:**
- Modify: `layouts/partials/body-map.html`

- [ ] **Step 1: Read the current body-map.html**

Open the file. Identify Relearn-specific CSS variable references (e.g. `var(--PRIMARY-color)`) and any references to `theme-mobility.css` classes.

The current partial uses a JS-driven hover-label pattern: it serializes a slug→label map as a `data-region-labels` JSON attribute and updates an empty `.body-map-label aria-live` div when a region is hovered. The JS that drives this lives in `custom-header.html` (which we delete in Task 3). **This UX is intentionally dropped in favor of a static, always-visible label grid below the figure.** Always-visible labels are more accessible, work without JS, and match the "as vanilla as possible" framing. If the static-label UX feels worse than expected during Task 14 verification, revisit then; do not pre-emptively port the JS hover pattern.

- [ ] **Step 2: Rewrite as a self-contained partial with front/back toggle**

```html
{{- $regions := .Site.Data.body_regions -}}
<div class="body-map-wrapper" data-view="front">
  <div class="body-map-toggle" role="radiogroup" aria-label="Body view">
    <input type="radio" name="body-view" id="body-view-front" value="front" checked>
    <label for="body-view-front">Front</label>
    <input type="radio" name="body-view" id="body-view-back" value="back">
    <label for="body-view-back">Back</label>
  </div>
  <div class="body-map-figures">
    <div class="body-map-figure body-map-figure-front" aria-hidden="false">
      {{ readFile "static/svg/body-front.svg" | safeHTML }}
    </div>
    <div class="body-map-figure body-map-figure-back" aria-hidden="true">
      {{ readFile "static/svg/body-back.svg" | safeHTML }}
    </div>
  </div>
  <div class="body-map-labels">
    {{ range $slug, $info := $regions }}
      <a href="/body-region/{{ $slug }}/" class="body-map-label" data-region="{{ $slug }}">
        {{ $info.label }}
      </a>
    {{ end }}
  </div>
</div>
```

(Adjust based on what's idiomatic in current `body-map.html` — preserve any existing structure that already works.)

- [ ] **Step 3: Verify no Relearn-era CSS variables remain in the file**

```bash
grep -E "var\(--(MAIN|PRIMARY|R-)" layouts/partials/body-map.html
```

Expected: no matches.

- [ ] **Step 4: Commit**

```bash
git add layouts/partials/body-map.html
git commit -m "Port body-map.html partial: vanilla classes, front/back toggle"
```

**Done when:** Partial uses no theme-specific variables and renders the body map with a front/back toggle.

---

### Task 13: Create `assets/css/body-map.css`

**Files:**
- Create: `assets/css/body-map.css`

- [ ] **Step 1: Write the CSS**

```css
/* Body map — vanilla CSS, no theme variables */

.body-map-wrapper {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  margin: 2rem auto;
  max-width: 600px;
}

.body-map-toggle {
  display: inline-flex;
  border: 1px solid currentColor;
  border-radius: 6px;
  overflow: hidden;
}

.body-map-toggle input[type="radio"] { position: absolute; opacity: 0; pointer-events: none; }
.body-map-toggle label {
  padding: 0.4rem 1rem;
  cursor: pointer;
  font-size: 0.9rem;
}
.body-map-toggle input:checked + label {
  background: currentColor;
  color: white;
}

.body-map-figures {
  position: relative;
  width: 100%;
  max-width: 360px;
}

.body-map-figure {
  display: none;
}

/* CSS-only view toggle: front shown by default, back shown when its radio is checked */
.body-map-wrapper:has(input#body-view-front:checked) .body-map-figure-front,
.body-map-wrapper:has(input#body-view-back:checked) .body-map-figure-back {
  display: block;
}

.body-map-svg { width: 100%; height: auto; }

.body-region {
  fill: currentColor;
  fill-opacity: 0.12;
  stroke: currentColor;
  stroke-opacity: 0.4;
  stroke-width: 0.5;
  transition: fill-opacity 0.15s;
  cursor: pointer;
}

.body-region:hover,
.body-region-link:focus .body-region {
  fill-opacity: 0.45;
}

.body-region-link:focus { outline: 2px solid currentColor; }

.body-map-labels {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 0.5rem;
  width: 100%;
}

.body-map-label {
  font-size: 0.85rem;
  text-decoration: none;
  padding: 0.3rem 0.5rem;
  border-radius: 4px;
  transition: background 0.1s;
}

.body-map-label:hover { background: rgba(127,127,127,0.1); }
```

- [ ] **Step 2: Verify Lotus picks it up**

Lotus Docs auto-loads `assets/css/` files via its asset pipeline. Confirm by reading Lotus's `head.html` partial:

```bash
hugo mod download
find ~/.cache/hugo_cache -name "head.html" -path "*lotusdocs*" | head -1 | xargs cat | grep -i css
```

If Lotus does not auto-load arbitrary `assets/css/` files, add a Lotus-aware include in `hugo.toml`:

```toml
[params.docs]
  customCSS = ["css/body-map.css"]
```

- [ ] **Step 3: Commit**

```bash
git add assets/css/body-map.css hugo.toml
git commit -m "Add body-map.css with hover/toggle styling"
```

**Done when:** Body map CSS file exists and is included in the Hugo build output.

---

### Task 14: Create `layouts/index.html` homepage override

**Files:**
- Create: `layouts/index.html`

- [ ] **Step 1: Write the homepage**

```html
{{ define "main" }}
  <section class="homepage-hero">
    <h1>{{ .Site.Title }}</h1>
    <p class="lead">{{ .Site.Params.docs.description | default "Practical mobility and recovery for wildland firefighters." }}</p>
  </section>
  <section class="homepage-body-map">
    {{ partial "body-map.html" . }}
  </section>
{{ end }}
```

If Lotus's base template uses a different block name (e.g. `body` or `content`), match it. Check `layouts/_default/baseof.html` in the Lotus Docs module.

- [ ] **Step 2: Verify in browser**

```bash
hugo server
```

Navigate to `http://localhost:1313/`. Confirm: title visible, body map renders, front/back toggle works, clicking a region navigates to `/body-region/<slug>/`.

- [ ] **Step 3: Commit**

```bash
git add layouts/index.html
git commit -m "Add homepage override mounting body map"
```

**Done when:** Homepage shows the body map; clicking a region routes correctly.

---

## Phase 5: Body region taxonomy + exercise-table shortcode

### Task 15: Port `layouts/body-region/term.html`

**Files:**
- Modify: `layouts/body-region/term.html`

- [ ] **Step 1: Read the current file**

Identify Relearn-specific shortcode usage (e.g. `{{< tabs >}}`, `{{% children %}}`) inside the template. Replace with plain Hugo `range` over `.Pages` grouped by content type:

```html
{{ define "main" }}
  {{ $regionSlug := .Data.Term }}
  {{ $regionInfo := index .Site.Data.body_regions $regionSlug }}
  <article>
    <h1>{{ $regionInfo.label }}</h1>
    <p>{{ $regionInfo.description }}</p>
    {{ partial "body-map.html" . }}
    <h2>Exercises</h2>
    <ul>
      {{ range .Pages.ByWeight }}
        <li><a href="{{ .RelPermalink }}">{{ .Title }}</a> — {{ .Description }}</li>
      {{ end }}
    </ul>
  </article>
{{ end }}
```

- [ ] **Step 2: Verify in browser**

```bash
hugo server
```

Navigate to `/body-region/hips/`. Expected: page renders with region label, description, body map (small or repeated, fine for now), and a list of all hip-tagged content.

- [ ] **Step 3: Commit**

```bash
git add layouts/body-region/term.html
git commit -m "Port body-region/term.html: vanilla Hugo, no Relearn shortcodes"
```

**Done when:** Each `/body-region/<slug>/` URL renders the region's tagged content list.

---

### Task 16: Port `layouts/body-region/terms.html`

**Files:**
- Modify: `layouts/body-region/terms.html`

- [ ] **Step 1: Read the current file**

- [ ] **Step 2: Rewrite as a vanilla terms list**

```html
{{ define "main" }}
  <article>
    <h1>Body Regions</h1>
    {{ partial "body-map.html" . }}
    <ul>
      {{ range .Data.Terms.ByCount }}
        <li>
          <a href="{{ .Page.RelPermalink }}">{{ (index $.Site.Data.body_regions .Page.Title).label | default .Page.Title }}</a>
          ({{ .Count }} pages)
        </li>
      {{ end }}
    </ul>
  </article>
{{ end }}
```

- [ ] **Step 3: Verify in browser**

Navigate to `/body-region/`. Expected: list of all 14 body regions with counts.

- [ ] **Step 4: Commit**

```bash
git add layouts/body-region/terms.html
git commit -m "Port body-region/terms.html: vanilla Hugo terms list"
```

**Done when:** `/body-region/` lists all regions with content counts.

---

### Task 17: Port `layouts/shortcodes/exercise-table.html` (drop `#` column)

**Files:**
- Modify: `layouts/shortcodes/exercise-table.html`

- [ ] **Step 1: Read current**

Current source:
```
{{- $pages := .Page.Pages.ByWeight -}}
{{- if gt (len $pages) 0 -}}
| # | Exercise | Focus |
|---|----------|-------|
{{- range $pages }}
| {{ strings.TrimRight " " .Params.menuPre }} | [{{ .Title }}]({{ .RelPermalink }}) | {{ with .Description }}{{ index (split . ".") 0 }}{{ end }} |
{{- end }}
{{- end -}}
```

- [ ] **Step 2: Rewrite without the `#` column**

```
{{- $pages := .Page.Pages.ByWeight -}}
{{- if gt (len $pages) 0 -}}
| Exercise | Focus |
|----------|-------|
{{- range $pages }}
| [{{ .Title }}]({{ .RelPermalink }}) | {{ with .Description }}{{ index (split . ".") 0 }}{{ end }} |
{{- end }}
{{- end -}}
```

- [ ] **Step 3: Verify each consuming page renders**

The six pages that use this shortcode:
- `content/mobility/lower-body/_index.md`
- `content/mobility/upper-body/_index.md`
- `content/mobility/spine-and-core/_index.md`
- `content/mobility/cars/_index.md`
- `content/strength/lower-body/_index.md`
- `content/strength/upper-body/_index.md`

```bash
hugo server
# Navigate to each of the six URLs above; confirm the table renders without `#` column and without errors
```

- [ ] **Step 4: Commit**

```bash
git add layouts/shortcodes/exercise-table.html
git commit -m "Simplify exercise-table shortcode: drop # column (menuPre removed)"
```

**Done when:** All six consuming pages render the table cleanly.

---

## Phase 6: Build pipeline + remaining setup

### Task 18: Update `Makefile`

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Replace contents**

```makefile
.PHONY: dev build clean

dev:
	hugo server --buildDrafts --disableFastRender

build:
	hugo --environment production

clean:
	rm -rf public/ resources/ .hugo_build.lock
```

- [ ] **Step 2: Test each target**

```bash
make clean && make build
ls public/index.html
```

Expected: clean exits without errors; build produces `public/index.html`.

- [ ] **Step 3: Commit**

```bash
git add Makefile
git commit -m "Simplify Makefile: drop Pagefind step"
```

**Done when:** `make build` produces a valid `public/` directory.

---

### Task 19: Update `netlify.toml`

**Files:**
- Modify: `netlify.toml`

The change here is minimal in intent: drop the Pagefind build step. **Preserve all existing `[[headers]]` blocks** (cache-control, security headers) — those are unrelated to the theme.

- [ ] **Step 1: Update build command and add Go version**

Edit `netlify.toml`. Change ONLY the `[build]` and `[build.environment]` blocks. Leave every `[[headers]]` block exactly as-is.

```toml
[build]
  command = "hugo --environment production"
  publish = "public"

[build.environment]
  HUGO_VERSION = "0.157.0"
  GO_VERSION = "1.21"
  # NODE_VERSION removed — no npm step needed (Pagefind dropped)
```

The headers section MUST remain untouched. Specifically these blocks must still exist after the edit (verify by diff):

- `for = "/pagefind/*"` immutable — keep even though Pagefind is dropped; harmless if no `/pagefind/` URLs exist, and trivial to remove later.
- `for = "/**/*.woff2"` immutable
- `for = "/**/*.css"` revalidate
- `for = "/**/*.js"` revalidate
- `for = "/**/*.html"` revalidate
- `for = "/*"` security headers (X-Frame-Options, X-Content-Type-Options, Referrer-Policy)

- [ ] **Step 2: Verify the file is valid TOML**

```bash
python3 -c "import tomllib; tomllib.loads(open('netlify.toml','rb').read())"
```

Expected: no error.

- [ ] **Step 3: Verify all original `[[headers]]` survived**

```bash
grep -c "^\[\[headers\]\]" netlify.toml
```

Expected: `6` (matches the original count). If less, restore from `git diff` and re-edit.

- [ ] **Step 4: Commit**

```bash
git add netlify.toml
git commit -m "Update Netlify build command for Lotus Docs (drop Pagefind/Node, preserve headers)"
```

**Done when:** Build command is Hugo-only, all six `[[headers]]` blocks are intact, file parses as valid TOML.

---

### Task 20: Final local verification

**Files:** None modified.

- [ ] **Step 1: Clean build from scratch**

```bash
make clean && make build
```

Expected: builds without errors. Inspect any warnings.

- [ ] **Step 2: Serve and click through 15 representative pages**

```bash
make dev
```

In a browser, walk the following list. Confirm each renders without errors and looks reasonable:

1. `/` (homepage with body map, toggle works)
2. `/body-region/` (terms list)
3. `/body-region/hips/` (single term)
4. `/body-region/shoulders/`
5. `/body-region/lower-back/`
6. `/mobility/lower-body/` (uses exercise-table shortcode)
7. `/mobility/upper-body/`
8. `/mobility/spine-and-core/`
9. One exercise page with tabs (e.g. an exercise with Media tab)
10. One exercise page with an alert/notice
11. `/routines/` and one routine page
12. `/concepts/` and one concept page
13. `/recovery/` and one recovery page
14. `/strength/lower-body/` (uses exercise-table)
15. Search bar — open it, search "hip flexor", verify hits

- [ ] **Step 3: Tag any issues found and fix in this task or a follow-up commit**

- [ ] **Step 4: Remove the worktree marker file**

```bash
rm PORT_IN_PROGRESS.txt
git add -A
git commit -m "Remove port-in-progress marker"
```

**Done when:** All 15 pages render, search returns hits, no console errors, no Hugo build warnings.

---

## Phase 7: Cutover

### Task 21: Push and verify Netlify deploy preview

**Files:** None modified.

- [ ] **Step 1: Push the branch**

```bash
git push -u origin lotus-port
```

- [ ] **Step 2: Watch Netlify deploy preview**

Netlify auto-creates a deploy preview for non-`main` branches if configured. URL pattern: `https://deploy-preview-<branch>--mobility-guide.netlify.app/` or similar; check the Netlify dashboard.

- [ ] **Step 3: Repeat the 15-page click-through on the deploy preview**

Same list as Task 20. Confirm parity with local.

- [ ] **Step 4: Spot-check internal links**

Use a link checker (e.g. `npx broken-link-checker https://<deploy-preview-url>/ -ro`) to find broken links. Fix any that appear.

**Done when:** Deploy preview matches local QA, no broken internal links.

---

### Task 22: Tag the last Relearn commit on `main`

**Files:** Git ref only.

- [ ] **Step 1: From CURRENT (main checkout), tag the last Relearn commit**

```bash
cd "/Users/dom/Documents/Claude/Projects/20-29 DMIHC Projects/24 mobility website development"
git checkout main
git log -1 --oneline
git tag relearn-final
git push origin relearn-final
```

This tag is the rollback point if anything goes wrong post-cutover.

**Done when:** `relearn-final` tag exists locally and on the remote.

---

### Task 23: Merge `lotus-port` into `main`

**Files:** Many — the merge brings in the entire port.

- [ ] **Step 1: Rollback rehearsal — confirm `relearn-final` still works**

Before merging, confirm the safety net is functional.

```bash
cd "/Users/dom/Documents/Claude/Projects/20-29 DMIHC Projects/24 mobility website development"
git checkout relearn-final
hugo server 2>&1 | head -10
```

Expected: Hugo serves the Relearn site without errors. Stop the server (Ctrl-C). Switch back to `main`:

```bash
git checkout main
```

If this fails, debug before proceeding — without a working rollback, the cutover has no safety net.

- [ ] **Step 2: Verify `main` has not advanced during the port**

```bash
git log main..lotus-port --oneline | head -3   # should show port commits
git log lotus-port..main --oneline             # should be EMPTY
```

If the second command returns commits, `main` has advanced (e.g. content edits in another session). In that case, before merging:
1. Rebase the port branch onto current `main`: `git checkout lotus-port && git rebase main`
2. Resolve conflicts. For Relearn-era files that the port deletes (e.g. `assets/css/theme-mobility.css`) but `main` modified, keep the deletion. For new content additions on `main`, keep the additions.
3. Re-run Task 20's local QA sweep before merging.

If the second command is empty (no advance), proceed to step 3.

- [ ] **Step 3: From CURRENT, merge the worktree branch**

```bash
git checkout main
git merge --no-ff lotus-port -m "Merge Lotus Docs port into main"
```

`--no-ff` preserves the branch history as a visible merge commit, useful for rollback if needed. Expected: clean merge with no conflicts (assuming step 2 was clean).

- [ ] **Step 4: Push to origin**

```bash
git push origin main
```

- [ ] **Step 5: Watch Netlify production build**

Netlify will trigger a build on push to `main`. Watch the build log. Expected: success.

- [ ] **Step 6: Visit the production URL**

Navigate to `https://mobility-guide.netlify.app/`. Confirm: body map, toggle, region clicks, search, sample exercise pages all work.

**Done when:** Production URL serves the Lotus Docs build, all Task 20 spot-checks pass on production.

---

### Task 24: Worktree cleanup

**Files:** Worktree removal.

- [ ] **Step 1: Remove the worktree**

```bash
cd "/Users/dom/Documents/Claude/Projects/20-29 DMIHC Projects/24 mobility website development"
git worktree remove ../24-mobility-lotusdocs
```

- [ ] **Step 2: Optionally delete the local branch**

```bash
git branch -d lotus-port
```

(Keep the remote branch for a few weeks as a recovery point. Delete via GitHub UI when comfortable.)

**Done when:** No `../24-mobility-lotusdocs` directory exists, only `main` is checked out.

---

### Task 25: Post-launch monitoring

**Files:** None modified.

- [ ] **Step 1: Watch Netlify deploy logs for the first 24 hours**

If any 404s spike or builds fail, investigate.

- [ ] **Step 2: Manual click-through one week post-launch**

Walk the same 15-page list. Confirm everything still renders.

- [ ] **Step 3: Collect any user-facing issues**

If issues appear, fix as commits to `main`. Do not rollback unless something is fundamentally broken — `relearn-final` is the safety net.

**Done when:** One week post-launch, no outstanding issues.

---

## Out of scope (explicit non-goals)

- Restoring the Source Serif / Inter fonts (Lotus defaults stay)
- Restoring the warm earth-tone palette (Lotus defaults stay; single accent override only if absolutely needed)
- Restoring the three-way Light/Auto/Dark theme toggle (Lotus's binary stays)
- Restoring the article-level body map context partial (dropped; taxonomy pages cover this)
- Restoring the difficulty badges (dropped; difficulty stays as a tag)
- Bolting Pagefind back on (FlexSearch suffices; revisit only if search quality is insufficient post-launch)
- Any new content authoring
- Bootstrap theme customization beyond the single optional accent color
- i18n, comments, analytics, or any feature not on the live Relearn site
