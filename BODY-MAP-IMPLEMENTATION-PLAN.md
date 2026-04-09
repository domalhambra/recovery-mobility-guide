# Body Map Implementation Plan

Goal: Add an interactive SVG body map as the homepage navigation, region-specific index pages using Hugo taxonomy, and contextual body graphics on article pages.

Architecture: SVG polygon data extracted from react-body-highlighter (MIT), served as Hugo partials with CSS-driven hover effects and a small vanilla JS layer for mobile two-tap interaction. A new `body-region` taxonomy drives the index pages, leveraging Relearn's tabs and children shortcodes for grouped content display.

Tech Stack: Hugo (Relearn theme), SVG, CSS custom properties, vanilla JS (~30 lines for mobile), TOML data files

---

## File Map

| Action | File | Responsibility |
|--------|------|----------------|
| Create | `data/body_regions.toml` | Source of truth: region slugs, labels, tag mappings, SVG IDs, view assignments |
| Create | `static/svg/body-front.svg` | Front view SVG with `<g id="region-*">` groups per zone |
| Create | `static/svg/body-back.svg` | Back view SVG with `<g id="region-*">` groups per zone |
| Create | `layouts/partials/body-map.html` | Reusable partial: inlines SVGs, wraps regions in links, renders label area |
| Create | `layouts/partials/body-map-context.html` | Small article-level partial: reads page body-region, renders relevant view(s) with highlights |
| Create | `layouts/shortcodes/body-map-context.html` | Shortcode wrapper so articles can use `{{</* body-map-context */>}}` if manual placement desired |
| Create | `layouts/taxonomy/body-region.html` | Taxonomy term page layout: body graphic + tabbed content index |
| Create | `layouts/taxonomy/body-region.terms.html` | Taxonomy terms list (the /body-region/ root page) |
| Create | `content/body-region/_index.md` | Chapter page for the body-region section root (if needed by Relearn) |
| Modify | `hugo.toml` | Add `body-region` taxonomy |
| Modify | `layouts/home/article.html` | Replace floating field with body map partial |
| Modify | `layouts/partials/custom-header.html` | Add body map CSS variables, SVG styles, hover/active states, mobile JS |
| Modify | `assets/css/theme-mobility.css` | Add light-mode body map CSS variables |
| Modify | `assets/css/theme-mobility-dark.css` | Add dark-mode body map CSS variables |
| Modify | `archetypes/default.md` | Add `body-region` field to default archetype |
| Modify | ~112 content `.md` files | Add `body-region = [...]` frontmatter based on existing tags |

---

## Task 1: Create the Data File

Files:
- Create: `data/body_regions.toml`

Step 1: Create the region mapping data file

```toml
# Body Region Definitions
# Each region maps to: SVG element IDs, display label, associated content tags, and which views it appears on.

[neck]
label = "Neck & Head"
svg_id = "region-neck"
tags = ["neck", "head"]
views = ["front", "back"]
description = "Neck mobility, forward head posture, and headache relief"

[shoulders]
label = "Shoulders"
svg_id = "region-shoulders"
tags = ["shoulders"]
views = ["front", "back"]
description = "Shoulder mobility, rotator cuff health, and overhead range of motion"

[arms]
label = "Arms & Wrists"
svg_id = "region-arms"
tags = ["arms", "wrists"]
views = ["front", "back"]
description = "Elbow, forearm, and wrist mobility for grip and upper extremity health"

[core]
label = "Core"
svg_id = "region-core"
tags = ["core"]
views = ["front"]
description = "Abdominal activation, anti-rotation, and trunk stability"

[hips]
label = "Hips"
svg_id = "region-hips"
tags = ["hips"]
views = ["front"]
description = "Hip flexor length, internal and external rotation, and pelvic mobility"

[quads]
label = "Quads & Knees"
svg_id = "region-quads"
tags = ["quadriceps", "knees"]
views = ["front"]
description = "Quadriceps flexibility, patellar tracking, and knee joint health"

[ankles]
label = "Shins & Ankles"
svg_id = "region-ankles"
tags = ["shins", "ankles"]
views = ["front"]
description = "Dorsiflexion range, ankle stability, and lower leg mobility"

[upper-back]
label = "Upper Back"
svg_id = "region-upper-back"
tags = ["upper-back"]
views = ["back"]
description = "Thoracic extension, scapular mobility, and postural correction"

[lower-back]
label = "Lower Back & Spine"
svg_id = "region-lower-back"
tags = ["lumbar", "spine"]
views = ["back"]
description = "Lumbar mobility, spinal decompression, and lower back pain management"

[glutes]
label = "Glutes"
svg_id = "region-glutes"
tags = ["glutes"]
views = ["back"]
description = "Glute activation, hip extension power, and posterior chain health"

[hamstrings]
label = "Hamstrings"
svg_id = "region-hamstrings"
tags = ["hamstrings"]
views = ["back"]
description = "Hamstring flexibility, posterior chain length, and hip hinge mechanics"

[calves]
label = "Calves"
svg_id = "region-calves"
tags = []
views = ["back"]
description = "Calf flexibility, Achilles tendon health, and plantarflexion range"
```

Step 2: Verify the file parses correctly

Run: `cd "/sessions/charming-friendly-wozniak/mnt/20-29 DMIHC Projects/24 mobility website development" && hugo config | grep -i body`
Expected: No errors. The data file should be accessible via `.Site.Data.body_regions` in templates.

Step 3: Commit

```bash
git add data/body_regions.toml
git commit -m "Add body region data file mapping SVG zones to tags and views"
```

---

## Task 2: Register the Taxonomy

Files:
- Modify: `hugo.toml`

Step 1: Add body-region taxonomy to the taxonomies block

Change:
```toml
[taxonomies]
  tag = "tags"
```

To:
```toml
[taxonomies]
  tag = "tags"
  body-region = "body-region"
```

Step 2: Verify Hugo recognizes the new taxonomy

Run: `hugo config | grep -A5 taxonomies`
Expected: Both `tag` and `body-region` listed.

Step 3: Commit

```bash
git add hugo.toml
git commit -m "Register body-region as a Hugo taxonomy"
```

---

## Task 3: Update Default Archetype

Files:
- Modify: `archetypes/default.md`

Step 1: Add body-region to the default archetype template

Change from:
```
+++
date = '{{ .Date }}'
draft = true
title = '{{ replace .File.ContentBaseName "-" " " | title }}'
+++
```

To:
```
+++
date = '{{ .Date }}'
draft = true
title = '{{ replace .File.ContentBaseName "-" " " | title }}'
body-region = []
+++
```

Step 2: Commit

```bash
git add archetypes/default.md
git commit -m "Add body-region field to default archetype"
```

---

## Task 4: Add body-region Frontmatter to Existing Content

Files:
- Modify: ~112 content markdown files across all sections

This task populates the `body-region` taxonomy values for every existing content page by cross-referencing each page's current `tags` against the tag mapping in `data/body_regions.toml`.

Step 1: Write a shell script to automate the frontmatter addition

Create a script `scripts/add-body-regions.sh` that:
1. Reads each `.md` file in `content/`
2. Extracts its `tags` array from the TOML frontmatter
3. Looks up which body regions those tags map to (using the mapping from Task 1)
4. If any matches found, inserts a `body-region = ["region1", "region2"]` line into the frontmatter
5. If no matches, skips the file (no empty `body-region = []` added)

The mapping logic (derived from `data/body_regions.toml`):
```
neck, head         → "neck"
shoulders          → "shoulders"
arms, wrists       → "arms"
core               → "core"
hips               → "hips"
quadriceps, knees  → "quads"
shins, ankles      → "ankles"
upper-back         → "upper-back"
lumbar, spine      → "lower-back"
glutes             → "glutes"
hamstrings         → "hamstrings"
```

```bash
#!/bin/bash
# add-body-regions.sh
# Adds body-region frontmatter to content pages based on existing tags

CONTENT_DIR="content"

# Tag → body-region mapping
declare -A TAG_TO_REGION=(
  [neck]="neck"
  [head]="neck"
  [shoulders]="shoulders"
  [arms]="arms"
  [wrists]="arms"
  [core]="core"
  [hips]="hips"
  [quadriceps]="quads"
  [knees]="quads"
  [shins]="ankles"
  [ankles]="ankles"
  [upper-back]="upper-back"
  [lumbar]="lower-back"
  [spine]="lower-back"
  [glutes]="glutes"
  [hamstrings]="hamstrings"
)

find "$CONTENT_DIR" -name "*.md" | while read -r file; do
  # Skip _index.md files (section pages)
  [[ "$(basename "$file")" == "_index.md" ]] && continue

  # Extract tags line from TOML frontmatter (between +++ delimiters)
  tags_line=$(sed -n '/^+++$/,/^+++$/p' "$file" | grep '^tags\s*=')
  [ -z "$tags_line" ] && continue

  # Parse individual tags
  tags=$(echo "$tags_line" | sed 's/tags\s*=\s*\[//;s/\]//;s/"//g;s/,/ /g' | xargs)

  # Build unique body-region list
  declare -A regions_seen=()
  regions=()
  for tag in $tags; do
    region="${TAG_TO_REGION[$tag]}"
    if [ -n "$region" ] && [ -z "${regions_seen[$region]}" ]; then
      regions+=("\"$region\"")
      regions_seen[$region]=1
    fi
  done
  unset regions_seen

  # Skip if no body regions matched
  [ ${#regions[@]} -eq 0 ] && continue

  # Format the body-region line
  region_str=$(IFS=', '; echo "${regions[*]}")
  body_region_line="body-region = [$region_str]"

  # Check if body-region already exists
  if grep -q '^body-region' "$file"; then
    echo "SKIP (already has body-region): $file"
    continue
  fi

  # Insert body-region line before the closing +++ of frontmatter
  # Find line number of second +++
  closing_line=$(awk '/^\+\+\+$/{c++; if(c==2){print NR; exit}}' "$file")
  if [ -n "$closing_line" ]; then
    sed -i "${closing_line}i\\${body_region_line}" "$file"
    echo "ADDED ($body_region_line): $file"
  fi
done
```

Step 2: Run the script

Run: `cd "/sessions/charming-friendly-wozniak/mnt/20-29 DMIHC Projects/24 mobility website development" && bash scripts/add-body-regions.sh`
Expected: Output showing which files got body-region values added, which were skipped.

Step 3: Manually review a sample of modified files

Run: `grep -r "body-region" content/ | head -20`
Expected: Files showing correct body-region values matching their tags.

Step 4: Verify Hugo builds cleanly

Run: `hugo --environment production 2>&1 | tail -5`
Expected: Clean build with no errors.

Step 5: Commit

```bash
git add content/ scripts/add-body-regions.sh
git commit -m "Add body-region taxonomy values to all content pages based on existing tag mapping"
```

---

## Task 5: Extract and Create SVG Files

Files:
- Create: `static/svg/body-front.svg`
- Create: `static/svg/body-back.svg`

Step 1: Clone react-body-highlighter and extract SVG polygon data

```bash
cd /tmp
git clone https://github.com/giavinh79/react-body-highlighter.git
```

Locate the SVG polygon data in the source. It's typically in a file like `src/components/Body.tsx` or similar, containing coordinate arrays for each muscle group for both anterior and posterior views.

Step 2: Convert polygon coordinate arrays to SVG `<polygon>` or `<path>` elements

For each body view (anterior/posterior), create an SVG file structured like this:

```xml
<!-- static/svg/body-front.svg -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 [width] [height]" class="body-map-svg body-map-front">
  <!-- Body outline (not clickable, just the silhouette) -->
  <g id="body-outline-front" class="body-outline">
    <!-- outline paths here -->
  </g>

  <!-- Clickable region groups -->
  <g id="region-neck" class="body-region" data-region="neck">
    <!-- head/neck polygon(s) from react-body-highlighter anterior data -->
    <polygon points="..." />
  </g>

  <g id="region-shoulders" class="body-region" data-region="shoulders">
    <!-- Merged: front-deltoids polygons -->
    <polygon points="..." />
  </g>

  <g id="region-arms" class="body-region" data-region="arms">
    <!-- Merged: biceps + forearm polygons -->
    <polygon points="..." />
  </g>

  <g id="region-core" class="body-region" data-region="core">
    <!-- Merged: abs + obliques polygons -->
    <polygon points="..." />
  </g>

  <g id="region-hips" class="body-region" data-region="hips">
    <!-- adductor / hip flexor area polygons -->
    <polygon points="..." />
  </g>

  <g id="region-quads" class="body-region" data-region="quads">
    <!-- quadriceps polygons -->
    <polygon points="..." />
  </g>

  <g id="region-ankles" class="body-region" data-region="ankles">
    <!-- calves (front/shin), ankle polygons -->
    <polygon points="..." />
  </g>
</svg>
```

The consolidation mapping for the front view:
- `region-neck` ← head + neck polygons
- `region-shoulders` ← front-deltoids polygons
- `region-arms` ← biceps + forearm polygons
- `region-core` ← abs + obliques polygons
- `region-hips` ← adductor polygons
- `region-quads` ← quadriceps polygons
- `region-ankles` ← calves (front-facing tibialis area) polygons

The consolidation mapping for the back view:
- `region-neck` ← neck polygons (back)
- `region-shoulders` ← back-deltoids + trapezius (upper) polygons
- `region-arms` ← triceps + forearm polygons
- `region-upper-back` ← upper-back + trapezius (mid/lower) polygons
- `region-lower-back` ← lower-back polygons
- `region-glutes` ← gluteal polygons
- `region-hamstrings` ← hamstring polygons
- `region-calves` ← calves polygons

Step 3: Ensure each `<g>` group has the proper attributes

Every clickable group needs:
- `id="region-{slug}"` matching `data/body_regions.toml` svg_id values
- `class="body-region"` for CSS targeting
- `data-region="{slug}"` for JS interaction

Step 4: Optimize SVGs

Run: `npx svgo static/svg/body-front.svg static/svg/body-back.svg --config='{"plugins":[{"name":"preset-default","params":{"overrides":{"removeViewBox":false,"cleanupIds":false}}}]}'`
Expected: Optimized file sizes, IDs and viewBox preserved.

Step 5: Verify SVGs render correctly

Open both SVGs in a browser to confirm all regions are visible and properly shaped.

Step 6: Commit

```bash
git add static/svg/body-front.svg static/svg/body-back.svg
git commit -m "Add front and back body map SVGs extracted from react-body-highlighter"
```

---

## Task 6: Add CSS Variables and Body Map Styles

Files:
- Modify: `assets/css/theme-mobility.css`
- Modify: `assets/css/theme-mobility-dark.css`
- Modify: `layouts/partials/custom-header.html`

Step 1: Add body map CSS variables to light theme

Append to `assets/css/theme-mobility.css`:

```css
  /* Body Map */
  --BODY-REGION-fill: #D4C8BB;
  --BODY-REGION-stroke: transparent;
  --BODY-REGION-hover-fill: #C9BAA9;
  --BODY-REGION-hover-stroke: #B84A28;
  --BODY-REGION-active-fill: rgba(184, 74, 40, 0.15);
  --BODY-REGION-active-stroke: #B84A28;
  --BODY-OUTLINE-fill: #E0D8CE;
  --BODY-MAP-label-color: #2A2520;
```

Step 2: Add body map CSS variables to dark theme

Append to `assets/css/theme-mobility-dark.css`:

```css
  /* Body Map */
  --BODY-REGION-fill: #3D352C;
  --BODY-REGION-stroke: transparent;
  --BODY-REGION-hover-fill: #4A3F34;
  --BODY-REGION-hover-stroke: #D4734E;
  --BODY-REGION-active-fill: rgba(212, 115, 78, 0.2);
  --BODY-REGION-active-stroke: #D4734E;
  --BODY-OUTLINE-fill: #2A2520;
  --BODY-MAP-label-color: #E8E2D8;
```

Step 3: Add body map structural CSS to custom-header.html

Add inside the existing `<style>` block in `layouts/partials/custom-header.html`, before the closing `</style>`:

```css
  /* ============================================
     Body Map — Interactive SVG navigation
     ============================================ */

  .body-map-container {
    display: flex;
    justify-content: center;
    align-items: flex-start;
    gap: 1.5rem;
    max-width: 36rem;
    margin: 1rem auto 0;
    padding: 0 1rem;
  }

  .body-map-container svg {
    width: 100%;
    max-width: 14rem;
    height: auto;
  }

  .body-map-heading {
    text-align: center;
    font-family: var(--MAIN-TITLES-font);
    font-weight: var(--MAIN-TITLES-H2-font-weight);
    color: var(--MAIN-TITLES-TEXT-color);
    margin-bottom: 0.25rem;
  }

  /* Region fill and stroke defaults */
  .body-region {
    fill: var(--BODY-REGION-fill);
    stroke: var(--BODY-REGION-stroke);
    stroke-width: 0;
    cursor: pointer;
    transition: fill 200ms ease, stroke 200ms ease, stroke-width 200ms ease, transform 200ms ease;
    transform-origin: center;
    transform-box: fill-box;
  }

  /* Body outline (non-interactive background silhouette) */
  .body-outline {
    fill: var(--BODY-OUTLINE-fill);
    pointer-events: none;
  }

  /* Desktop hover */
  @media (hover: hover) {
    .body-region:hover {
      fill: var(--BODY-REGION-hover-fill);
      stroke: var(--BODY-REGION-hover-stroke);
      stroke-width: 2px;
      transform: scale(1.05);
    }
  }

  /* Active/selected state (mobile first tap, or desktop for parity) */
  .body-region.is-active {
    fill: var(--BODY-REGION-active-fill);
    stroke: var(--BODY-REGION-active-stroke);
    stroke-width: 2.5px;
    transform: scale(1.05);
  }

  /* Region label (shared element below the SVGs) */
  .body-map-label {
    text-align: center;
    font-family: var(--MAIN-TITLES-font);
    font-size: 1.1rem;
    font-weight: 500;
    color: var(--BODY-MAP-label-color);
    min-height: 1.6em;
    margin-top: 0.75rem;
    transition: opacity 150ms ease;
  }

  .body-map-label:empty {
    opacity: 0;
  }

  /* Reduce motion */
  @media (prefers-reduced-motion: reduce) {
    .body-region {
      transition-duration: 0.01ms !important;
    }
  }

  /* Mobile layout */
  @media (max-width: 480px) {
    .body-map-container {
      gap: 0.75rem;
    }
    .body-map-container svg {
      max-width: 10rem;
    }
  }

  /* ============================================
     Body Map Context — small article-level graphic
     ============================================ */

  .body-map-context {
    float: right;
    display: flex;
    gap: 0.5rem;
    margin: 0 0 1rem 1.5rem;
  }

  .body-map-context svg {
    width: 5rem;
    height: auto;
  }

  /* In context mode, non-highlighted regions are very faint */
  .body-map-context .body-region {
    fill: var(--BODY-OUTLINE-fill);
    cursor: default;
    pointer-events: none;
  }

  .body-map-context .body-region.is-highlighted {
    fill: var(--BODY-REGION-active-fill);
    stroke: var(--BODY-REGION-active-stroke);
    stroke-width: 2px;
  }

  .body-map-context .body-outline {
    opacity: 0.5;
  }

  @media (max-width: 480px) {
    .body-map-context {
      float: none;
      justify-content: center;
      margin: 0 auto 1rem;
    }
  }
```

Step 4: Add mobile two-tap JS to custom-header.html

Add inside the existing `<script>` block in `layouts/partials/custom-header.html`, inside the `DOMContentLoaded` listener, after the floating field code (which will be removed in Task 8, but the JS section persists):

```javascript
  // ============================================
  // Body Map — mobile two-tap navigation
  // ============================================
  var bodyMapContainer = document.querySelector('.body-map-container');
  if (bodyMapContainer) {
    var isTouchDevice = ('ontouchstart' in window) || (navigator.maxTouchPoints > 0);
    var activeRegion = null;
    var label = bodyMapContainer.parentElement.querySelector('.body-map-label');

    if (isTouchDevice) {
      bodyMapContainer.addEventListener('click', function(e) {
        var regionEl = e.target.closest('.body-region');

        // Tap on empty space — deselect
        if (!regionEl) {
          if (activeRegion) {
            activeRegion.classList.remove('is-active');
            activeRegion = null;
            if (label) label.textContent = '';
          }
          return;
        }

        var link = regionEl.closest('a');
        var regionSlug = regionEl.dataset.region;

        // Second tap on same region — navigate
        if (activeRegion === regionEl && link) {
          window.location.href = link.getAttribute('href');
          return;
        }

        // First tap — select and show label
        e.preventDefault();
        if (activeRegion) activeRegion.classList.remove('is-active');
        regionEl.classList.add('is-active');
        activeRegion = regionEl;

        if (label && regionSlug) {
          // Look up label from data attribute on container
          var labels = JSON.parse(bodyMapContainer.dataset.regionLabels || '{}');
          label.textContent = labels[regionSlug] || regionSlug;
        }
      });
    } else {
      // Desktop: show label on hover
      var regions = bodyMapContainer.querySelectorAll('.body-region');
      regions.forEach(function(region) {
        region.addEventListener('mouseenter', function() {
          if (label) {
            var labels = JSON.parse(bodyMapContainer.dataset.regionLabels || '{}');
            label.textContent = labels[region.dataset.region] || region.dataset.region;
          }
        });
        region.addEventListener('mouseleave', function() {
          if (label) label.textContent = '';
        });
      });
    }
  }
```

Step 5: Verify no syntax errors in CSS or JS

Run: `hugo server` and check browser console.
Expected: No errors, site loads normally.

Step 6: Commit

```bash
git add assets/css/theme-mobility.css assets/css/theme-mobility-dark.css layouts/partials/custom-header.html
git commit -m "Add body map CSS variables, hover/active styles, and mobile two-tap JS"
```

---

## Task 7: Create the Body Map Partial

Files:
- Create: `layouts/partials/body-map.html`

Step 1: Write the body map partial

This partial renders the full interactive body map for the homepage. It inlines both SVGs, wraps each region group in an `<a>` tag linking to the taxonomy term page, and outputs the shared label element.

```html
{{/* Body Map — interactive homepage navigation */}}
{{/* Builds a JSON object of region labels for JS and wraps SVG regions in links */}}

{{ $regions := .Site.Data.body_regions }}

{{/* Build label lookup for JS */}}
{{ $labelMap := dict }}
{{ range $slug, $region := $regions }}
  {{ $labelMap = merge $labelMap (dict $slug $region.label) }}
{{ end }}

<h2 class="body-map-heading">Choose a body region</h2>

<div class="body-map-container" data-region-labels='{{ $labelMap | jsonify }}'>

  {{/* Front view */}}
  <div class="body-map-view body-map-view--front">
    {{ $frontSVG := readFile "static/svg/body-front.svg" }}
    {{/* Hugo doesn't natively support wrapping SVG groups in links at build time.
         We inject the SVG raw and use JS to wrap regions in links,
         OR we pre-process the SVG to include <a> tags.

         Approach: Pre-include <a> wrappers in the SVG file itself.
         Each <g class="body-region"> is already wrapped in:
         <a href="/body-region/{slug}/" class="body-region-link">

         Alternatively, use Hugo's replaceRE to inject links at build time: */}}
    {{ range $slug, $region := $regions }}
      {{ if in $region.views "front" }}
        {{ $find := printf `(<g[^>]*id="%s"[^>]*>)` $region.svg_id }}
        {{ $replace := printf `<a href="/body-region/%s/" class="body-region-link">$1` $slug }}
        {{ $frontSVG = replaceRE $find $replace $frontSVG }}
        {{ $findClose := printf `(</g>)(<!--\s*/%s\s*-->)` $region.svg_id }}
        {{ $replaceClose := `$1</a>$2` }}
        {{ $frontSVG = replaceRE $findClose $replaceClose $frontSVG }}
      {{ end }}
    {{ end }}
    {{ $frontSVG | safeHTML }}
  </div>

  {{/* Back view */}}
  <div class="body-map-view body-map-view--back">
    {{ $backSVG := readFile "static/svg/body-back.svg" }}
    {{ range $slug, $region := $regions }}
      {{ if in $region.views "back" }}
        {{ $find := printf `(<g[^>]*id="%s"[^>]*>)` $region.svg_id }}
        {{ $replace := printf `<a href="/body-region/%s/" class="body-region-link">$1` $slug }}
        {{ $backSVG = replaceRE $find $replace $backSVG }}
        {{ $findClose := printf `(</g>)(<!--\s*/%s\s*-->)` $region.svg_id }}
        {{ $replaceClose := `$1</a>$2` }}
        {{ $backSVG = replaceRE $findClose $replaceClose $backSVG }}
      {{ end }}
    {{ end }}
    {{ $backSVG | safeHTML }}
  </div>

</div>

<div class="body-map-label" aria-live="polite"></div>
```

**Important SVG authoring note:** For the `replaceRE` link-injection approach to work, each `<g>` closing tag in the SVG files needs an adjacent comment marker like `</g><!-- /region-shoulders -->`. An alternative (and simpler) approach is to pre-bake the `<a>` wrappers directly into the SVG files during Task 5, using `<a xlink:href="/body-region/shoulders/">` around each `<g>`. This avoids regex complexity entirely. **The pre-baked approach is recommended.** In that case, this partial simplifies to:

```html
{{ $regions := .Site.Data.body_regions }}
{{ $labelMap := dict }}
{{ range $slug, $region := $regions }}
  {{ $labelMap = merge $labelMap (dict $slug $region.label) }}
{{ end }}

<h2 class="body-map-heading">Choose a body region</h2>

<div class="body-map-container" data-region-labels='{{ $labelMap | jsonify }}'>
  <div class="body-map-view body-map-view--front">
    {{ readFile "static/svg/body-front.svg" | safeHTML }}
  </div>
  <div class="body-map-view body-map-view--back">
    {{ readFile "static/svg/body-back.svg" | safeHTML }}
  </div>
</div>

<div class="body-map-label" aria-live="polite"></div>
```

Use the simpler version. Pre-bake links into the SVGs.

Step 2: Verify partial renders

Run: `hugo server` and navigate to homepage (after Task 8 integrates it).

Step 3: Commit

```bash
git add layouts/partials/body-map.html
git commit -m "Create body map partial with inlined SVGs and label element"
```

---

## Task 8: Replace the Homepage Layout

Files:
- Modify: `layouts/home/article.html`

Step 1: Replace the floating field section with the body map partial

Change the full file to:

```html

<article class="home">
  <header class="headline">
    {{- partial "content-header.html" . }}
  </header>
{{ partial "heading-pre.html" . }}<h1 id="{{ anchorize .LinkTitle }}">{{ .LinkTitle }}</h1>{{ partial "heading-post.html" . }}

{{ partial "article-content.html" . }}

  {{/* Body Map — interactive region navigation */}}
  {{ partial "body-map.html" . }}

  <footer class="footline">
    {{- partial "content-footer.html" . }}
  </footer>
</article>
```

Step 2: Remove floating field CSS from custom-header.html

Delete the entire `/* Floating Field */` CSS section and the floating field JS animation code from `layouts/partials/custom-header.html`. This includes:
- The `.floating-field`, `.floating-field-inner`, `.floating-drift`, `.floating-link` CSS rules (and all their variants, dark mode overrides, and responsive rules)
- The JS block starting with `// Floating field drift animation` through its closing brace

Step 3: Verify homepage renders with body map

Run: `hugo server`
Expected: Homepage shows "Choose a body region" heading with front and back SVGs. No floating field remnants.

Step 4: Commit

```bash
git add layouts/home/article.html layouts/partials/custom-header.html
git commit -m "Replace floating field homepage with interactive body map"
```

---

## Task 9: Create the Article Context Partial and Shortcode

Files:
- Create: `layouts/partials/body-map-context.html`
- Create: `layouts/shortcodes/body-map-context.html`

Step 1: Write the context partial

This partial reads the current page's `body-region` values, determines which views are needed, and renders small SVGs with the relevant regions highlighted.

```html
{{/* Body Map Context — small highlighted body graphic for article pages */}}
{{/* Only renders if the page has body-region values */}}

{{ $pageRegions := .Params.body_region }}
{{ if $pageRegions }}
  {{ $allRegions := .Site.Data.body_regions }}

  {{/* Determine which views are needed */}}
  {{ $needFront := false }}
  {{ $needBack := false }}
  {{ range $pageRegions }}
    {{ $regionData := index $allRegions . }}
    {{ if $regionData }}
      {{ if in $regionData.views "front" }}
        {{ $needFront = true }}
      {{ end }}
      {{ if in $regionData.views "back" }}
        {{ $needBack = true }}
      {{ end }}
    {{ end }}
  {{ end }}

  {{/* Build a list of active SVG IDs for JS/CSS targeting */}}
  {{ $activeIDs := slice }}
  {{ range $pageRegions }}
    {{ $regionData := index $allRegions . }}
    {{ if $regionData }}
      {{ $activeIDs = $activeIDs | append $regionData.svg_id }}
    {{ end }}
  {{ end }}

  <div class="body-map-context" data-active-regions='{{ $activeIDs | jsonify }}'>
    {{ if $needFront }}
    <div class="body-map-view body-map-view--front">
      {{ readFile "static/svg/body-front.svg" | safeHTML }}
    </div>
    {{ end }}
    {{ if $needBack }}
    <div class="body-map-view body-map-view--back">
      {{ readFile "static/svg/body-back.svg" | safeHTML }}
    </div>
    {{ end }}
  </div>

  {{/* Inline script to add .is-highlighted class to active regions */}}
  <script>
  (function() {
    var ctx = document.querySelector('.body-map-context');
    if (!ctx) return;
    var active = JSON.parse(ctx.dataset.activeRegions || '[]');
    active.forEach(function(id) {
      var els = ctx.querySelectorAll('#' + id);
      els.forEach(function(el) { el.classList.add('is-highlighted'); });
    });
  })();
  </script>
{{ end }}
```

Step 2: Write the shortcode wrapper

```html
{{/* Shortcode: body-map-context
     Usage: {{</* body-map-context */>}}
     Renders the small contextual body graphic for the current page */}}
{{ partial "body-map-context.html" .Page }}
```

Step 3: Decide on automatic vs. manual insertion

There are two approaches for getting the context graphic onto article pages:

**Option A (Automatic):** Override the default single-page layout to include the partial automatically for any page with `body-region` values. Create `layouts/_default/single.html` that extends Relearn's default but inserts the partial at the top of the content area.

**Option B (Manual):** Authors add `{{</* body-map-context */>}}` to individual pages where they want the graphic.

**Recommended: Option A** for consistency. To do this, copy Relearn's `layouts/_default/views/article.html` into the project's `layouts/_default/views/article.html` and add the partial call at the start of the content section. Consult the Relearn theme's actual layout structure to find the correct insertion point.

Step 4: Verify on an article page with body-region values

Run: `hugo server` and navigate to a page like `/mobility/lower-body/lazy-lizard/`
Expected: Small body graphic in top-right with "hips" region highlighted on the front view only.

Step 5: Commit

```bash
git add layouts/partials/body-map-context.html layouts/shortcodes/body-map-context.html
git commit -m "Create article-level contextual body map partial and shortcode"
```

---

## Task 10: Create Taxonomy Term Page Layout

Files:
- Create: `layouts/body-region/taxonomy.html` (or `layouts/taxonomy/body-region.html` depending on Hugo version)
- Create: `layouts/body-region/term.html` (or `layouts/taxonomy/body-region.terms.html`)

Step 1: Determine correct layout file path

Hugo's layout lookup order for taxonomy term pages varies by version. For Hugo 0.157+, the preferred paths are:

- Term page (e.g. `/body-region/shoulders/`): `layouts/body-region/term.html`
- Terms list (e.g. `/body-region/`): `layouts/body-region/terms.html`

Verify by checking Hugo docs or testing. If those don't work, try `layouts/taxonomy/body-region.html` and `layouts/taxonomy/body-region.terms.html`.

Step 2: Write the term page layout (individual region page)

This layout needs to work within Relearn's framework. The cleanest approach is to extend Relearn's base layout and inject custom content. Create `layouts/body-region/term.html`:

```html
{{ define "main" }}
<article class="default">
  <header class="headline">
    {{- partial "content-header.html" . }}
  </header>

  {{ partial "heading-pre.html" . }}<h1 id="{{ anchorize .Title }}">{{ .Title }}</h1>{{ partial "heading-post.html" . }}

  {{/* Region description from data file */}}
  {{ $regionSlug := .Title | urlize }}
  {{ $regionData := index .Site.Data.body_regions $regionSlug }}

  {{/* Contextual body graphic */}}
  {{ if $regionData }}
    {{ $activeIDs := slice $regionData.svg_id }}
    <div class="body-map-context" data-active-regions='{{ $activeIDs | jsonify }}'>
      {{ if in $regionData.views "front" }}
      <div class="body-map-view body-map-view--front">
        {{ readFile "static/svg/body-front.svg" | safeHTML }}
      </div>
      {{ end }}
      {{ if in $regionData.views "back" }}
      <div class="body-map-view body-map-view--back">
        {{ readFile "static/svg/body-back.svg" | safeHTML }}
      </div>
      {{ end }}
    </div>
    <script>
    (function() {
      var ctx = document.querySelector('.body-map-context');
      if (!ctx) return;
      var active = JSON.parse(ctx.dataset.activeRegions || '[]');
      active.forEach(function(id) {
        var els = ctx.querySelectorAll('#' + id);
        els.forEach(function(el) { el.classList.add('is-highlighted'); });
      });
    })();
    </script>

    {{ with $regionData.description }}
    <p>{{ . }}</p>
    {{ end }}
  {{ end }}

  {{/* Group pages by section using tabs */}}
  {{ $pages := .Pages }}

  {{/* Define sections in display order */}}
  {{ $sections := slice
    (dict "path" "mobility" "label" "Mobility Exercises" "icon" "🔄")
    (dict "path" "warm-up" "label" "Warm-Up & Activation" "icon" "🔥")
    (dict "path" "strength" "label" "Strength & Conditioning" "icon" "💪")
    (dict "path" "recovery" "label" "Recovery & Restoration" "icon" "🧊")
    (dict "path" "pain-prescriptions" "label" "Pain Prescriptions" "icon" "🩹")
  }}

  {{/* Check which sections have content */}}
  {{ $activeSections := slice }}
  {{ range $section := $sections }}
    {{ $sectionPages := where $pages "Section" $section.path }}
    {{ if gt (len $sectionPages) 0 }}
      {{ $activeSections = $activeSections | append (merge $section (dict "pages" $sectionPages)) }}
    {{ end }}
  {{ end }}

  {{ if gt (len $activeSections) 0 }}
    {{/* If only one section has content, skip tabs and show directly */}}
    {{ if eq (len $activeSections) 1 }}
      {{ $s := index $activeSections 0 }}
      <h2>{{ $s.label }}</h2>
      <div class="body-region-page-list">
        {{ range $s.pages }}
        <div class="body-region-page-item">
          <a href="{{ .RelPermalink }}"><strong>{{ .Title }}</strong></a>
          {{ with .Description }}<br><span class="body-region-page-desc">{{ . }}</span>{{ end }}
        </div>
        {{ end }}
      </div>
    {{ else }}
      {{/* Multiple sections: use Relearn tabs.
           Since this is a layout (not content), we render tab markup directly
           rather than using the shortcode. */}}
      <div class="tab-panel">
        {{ range $i, $s := $activeSections }}
        <details {{ if eq $i 0 }}open{{ end }}>
          <summary>{{ $s.label }}</summary>
          <div class="body-region-page-list">
            {{ range $s.pages }}
            <div class="body-region-page-item">
              <a href="{{ .RelPermalink }}"><strong>{{ .Title }}</strong></a>
              {{ with .Description }}<br><span class="body-region-page-desc">{{ . }}</span>{{ end }}
            </div>
            {{ end }}
          </div>
        </details>
        {{ end }}
      </div>
    {{ end }}
  {{ else }}
    <p>No exercises have been added for this body region yet.</p>
  {{ end }}

  <footer class="footline">
    {{- partial "content-footer.html" . }}
  </footer>
</article>
{{ end }}
```

**Note:** The layout above uses `<details>/<summary>` as a fallback for section grouping. The ideal approach is to use Relearn's actual tab markup. Consult `themes/hugo-theme-relearn/layouts/shortcodes/tabs.html` and `tab.html` to replicate their HTML structure so the built-in tab JS and styling kicks in. The `<details>` approach works as a progressive enhancement fallback.

Step 3: Add CSS for the region page list items

Add to the body map CSS section in `custom-header.html`:

```css
  /* Body region term page — content listing */
  .body-region-page-list {
    margin: 0.75rem 0 1.5rem;
  }

  .body-region-page-item {
    padding: 0.5rem 0;
    border-bottom: 1px solid var(--MENU-HEADER-BORDER-color);
  }

  .body-region-page-item:last-child {
    border-bottom: none;
  }

  .body-region-page-item a {
    font-family: var(--MAIN-TITLES-font);
    font-weight: 500;
  }

  .body-region-page-desc {
    font-size: 0.9rem;
    color: var(--MENU-VISITED-color);
  }

  .tab-panel summary {
    font-family: var(--MAIN-TITLES-font);
    font-weight: 600;
    font-size: 1.1rem;
    cursor: pointer;
    padding: 0.5rem 0;
    color: var(--MAIN-TITLES-TEXT-color);
  }

  .tab-panel details {
    border-bottom: 1px solid var(--MENU-HEADER-BORDER-color);
    margin-bottom: 0.25rem;
  }
```

Step 4: Write the terms list layout (the /body-region/ root page)

Create `layouts/body-region/terms.html`:

```html
{{ define "main" }}
<article class="default">
  <header class="headline">
    {{- partial "content-header.html" . }}
  </header>

  {{ partial "heading-pre.html" . }}<h1 id="body-regions">Body Regions</h1>{{ partial "heading-post.html" . }}

  <p>Select a body region to explore exercises, warm-ups, recovery protocols, and pain prescriptions.</p>

  {{/* Render the full interactive body map */}}
  {{ partial "body-map.html" . }}

  <footer class="footline">
    {{- partial "content-footer.html" . }}
  </footer>
</article>
{{ end }}
```

Step 5: Check that Relearn's base template is being extended properly

The layouts above use `{{ define "main" }}`. Relearn's base template (`baseof.html`) must define a `main` block. Verify by checking `themes/hugo-theme-relearn/layouts/_default/baseof.html`. If Relearn uses a different block name, adjust accordingly.

Step 6: Verify taxonomy pages generate

Run: `hugo server` and navigate to `/body-region/` and `/body-region/shoulders/`
Expected: Terms list shows the body map. Term page shows the contextual graphic, description, and grouped content listing.

Step 7: Commit

```bash
git add layouts/body-region/
git commit -m "Create taxonomy term and terms list layouts for body-region pages"
```

---

## Task 11: Handle Sidebar Navigation for Body Regions

Files:
- Possibly modify: `hugo.toml` (menu configuration)

Step 1: Decide whether body-region pages should appear in the sidebar

The body-region taxonomy pages exist at `/body-region/` but aren't part of the content section hierarchy, so they won't appear in Relearn's auto-generated sidebar by default. Options:

**Option A:** Add a menu entry in `hugo.toml` pointing to `/body-region/` so it appears in the sidebar as a top-level link.
**Option B:** Don't add it to the sidebar. The body map on the homepage is the primary entry point, and the body-region pages are navigated via the SVG.

**Recommended: Option A** with a single top-level link. Add to `hugo.toml`:

```toml
[[menus.main]]
  name = "Body Regions"
  url = "/body-region/"
  weight = 5
```

Then configure Relearn's sidebar menus to include `main` if not already present. Check existing `[params]` sidebar configuration.

Step 2: Verify sidebar shows the link

Run: `hugo server` and check sidebar.
Expected: "Body Regions" link appears and navigates to `/body-region/`.

Step 3: Commit

```bash
git add hugo.toml
git commit -m "Add Body Regions link to sidebar navigation"
```

---

## Task 12: Final Verification and Cleanup

Step 1: Full build test

Run: `hugo --environment production 2>&1`
Expected: Clean build, no errors or warnings related to body-region or SVG files.

Step 2: Verify all 12 region pages exist

Run: `hugo list all | grep body-region`
Expected: 12 term pages listed (neck, shoulders, arms, core, hips, quads, ankles, upper-back, lower-back, glutes, hamstrings, calves).

Step 3: Test light/dark mode switching

Navigate to the homepage, switch between Light, Auto, and Dark modes. Verify the body map SVG colors update correctly in all three states.

Step 4: Test mobile two-tap behavior

Open dev tools, toggle device emulation (or test on a real phone). Verify:
- First tap on a region highlights it and shows the label
- Second tap navigates to the region page
- Tapping a different region switches the selection
- Tapping empty space deselects

Step 5: Test contextual body graphic on articles

Navigate to several article pages with different body-region values:
- A page with a single front-only region (e.g. hips)
- A page with a single back-only region (e.g. upper-back)
- A page with a region on both views (e.g. shoulders)
- A page with multiple regions
- A page with no body-region (should show nothing)

Step 6: Test region index page content grouping

Navigate to a region with content across multiple sections (e.g. `/body-region/shoulders/`). Verify the content is grouped by section with expandable details/tabs.

Step 7: Run Pagefind re-index

Run: `npx -y pagefind --site public`
Expected: Search index includes the new body-region pages.

Step 8: Remove the migration script

Run: `rm scripts/add-body-regions.sh` (or keep it for future use if desired).

Step 9: Commit

```bash
git add -A
git commit -m "Final cleanup and verification of body map feature"
```

---

## Summary of All New/Modified Files

**New files (8):**
- `data/body_regions.toml`
- `static/svg/body-front.svg`
- `static/svg/body-back.svg`
- `layouts/partials/body-map.html`
- `layouts/partials/body-map-context.html`
- `layouts/shortcodes/body-map-context.html`
- `layouts/body-region/term.html`
- `layouts/body-region/terms.html`

**Modified files (6 + ~112 content files):**
- `hugo.toml` (taxonomy + menu)
- `layouts/home/article.html` (replace floating field)
- `layouts/partials/custom-header.html` (add CSS + JS, remove floating field CSS/JS)
- `assets/css/theme-mobility.css` (add CSS variables)
- `assets/css/theme-mobility-dark.css` (add CSS variables)
- `archetypes/default.md` (add body-region field)
- ~112 content `.md` files (add body-region frontmatter)

**Optional files (1):**
- `scripts/add-body-regions.sh` (migration helper, can be removed after use)
