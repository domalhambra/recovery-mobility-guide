# Component Map

Visual-first reference for finding what to edit. Organized by what you see on
the page, not by file. Each entry maps a visible element to the files and CSS
selectors that control it.

Line numbers are approximate — check the file if they've drifted.


## Homepage

### Body text (h1, paragraphs, lists)
The prose content above the body map.

| What | Where |
|------|-------|
| Template | `layouts/home/article.html` (wraps in `article.home`) |
| Content source | `content/_index.md` |
| Max-width | `custom-header.html:39-44` — `article.home > h1, > p, > ul, > ol` at `max-width: 40rem` |
| Typography | `custom-header.html:12-26` — `:root` font variables |
| Line-height | `custom-header.html:53-56` — `#body p, #body li` at `1.6` |
| Link underline effect | `custom-header.html:70-77` — `#body a:not(.term-link):not(.anchor)` gradient background |

To change centering or width of the body text independently from the body map,
edit the `article.home` selectors at lines 39-44. The body map has its own
container (`.body-map-container`) with separate centering — see next entry.

### Body map (interactive front/back SVGs)
The two-figure anatomical diagram with hover/tap regions.

| What | Where |
|------|-------|
| Template | `layouts/partials/body-map.html` — builds container, inlines both SVGs |
| Called from | `layouts/home/article.html:11` |
| Region data | `data/body_regions.toml` — labels, SVG IDs, views, descriptions |
| Front SVG | `static/svg/body-front.svg` — polygon regions + outline path |
| Back SVG | `static/svg/body-back.svg` — polygon regions + outline path |
| Container layout | `custom-header.html:358-366` — `.body-map-container` flex, centered, `max-width: 36rem`, gap `1.5rem` |
| SVG sizing | `custom-header.html:368-372` — `.body-map-container svg` at `max-width: 14rem` |
| Heading | `custom-header.html:374-380` — `.body-map-heading` |
| Region fills/strokes | `custom-header.html:383-391` — `.body-region` base styles; colors from CSS vars `--BODY-REGION-*` |
| Region colors (light) | `assets/css/theme-mobility.css` — `--BODY-REGION-fill`, `-hover-fill`, `-active-fill`, `-stroke`, etc. |
| Region colors (dark) | `assets/css/theme-mobility-dark.css` — same variables, dark palette |
| Outline silhouette | `custom-header.html:394-397` — `.body-outline` fill from `--BODY-OUTLINE-fill` |
| Hover effect | `custom-header.html:400-407` — `@media (hover: hover)` `.body-region:hover` scale + stroke |
| Active/tap state | `custom-header.html:410-415` — `.body-region.is-active` |
| Label below SVGs | `custom-header.html:418-431` — `.body-map-label` text styling |
| Mobile sizing | `custom-header.html:441-448` — `@media (max-width: 480px)` reduces SVG to `10rem`, gap to `0.75rem` |
| Link underline removal | `custom-header.html:451-455` — `.body-region-link` overrides |
| JS: mobile two-tap | `custom-header.html:702-757` — touch detection, first-tap highlight, second-tap navigate |
| JS: desktop hover labels | `custom-header.html:743-756` — mouseenter/mouseleave label updates |


## Article Pages (exercises, concepts, etc.)

### "On this page" / inline TOC
The collapsible table of contents at the top of article pages.

| What | Where |
|------|-------|
| Template | `layouts/partials/content-header.html:25-33` — renders if page has enough headings |
| Container | `custom-header.html:171-181` — `.inline-toc` border, padding, `max-width: 24rem`, centered |
| Summary header | `custom-header.html:183-188` — `.inline-toc summary` at `font-weight: 600` |
| List indentation | `custom-header.html:197-199` — `.inline-toc ul ul` at `padding-left: 1.25rem` |
| Link styling | `custom-header.html:206-215` — `.inline-toc a` color and hover |
| High-contrast mode | `custom-header.html:346-348` — `@media (forced-colors: active)` thicker border |
| Heading level range | `hugo.toml` — `[markup.tableOfContents]` startLevel 2, endLevel 3 |

### Difficulty badge + reading time
The colored badge (Beginner/Intermediate/Advanced) and "X min read" next to it.

| What | Where |
|------|-------|
| Template | `layouts/partials/content-header.html:2-23` — extracts difficulty from frontmatter or tags |
| Container | `custom-header.html:262-269` — `.page-meta` flex row |
| Badge base | `custom-header.html:271-278` — `.meta-difficulty` pill shape |
| Beginner (green) | `custom-header.html:280-283` — `.meta-difficulty--beginner` |
| Intermediate (yellow) | `custom-header.html:285-288` — `.meta-difficulty--intermediate` |
| Advanced (red) | `custom-header.html:290-293` — `.meta-difficulty--advanced` |
| Reading time | `custom-header.html:295-297` — `.meta-reading-time` |

### Tags row
Tag pills displayed above the content.

| What | Where |
|------|-------|
| Template | `layouts/partials/content-header.html:1` — calls Relearn's `tags.html` partial |
| Tag colors (light) | `assets/css/theme-mobility.css` — `--TAG-BG-color` (#B84A28), tag arrow pseudo-elements |
| Tag colors (dark) | `assets/css/theme-mobility-dark.css` — same variables |

### Body diagram (small, floated right)
The small highlighted body graphic that appears on article pages.

| What | Where |
|------|-------|
| Template | `layouts/partials/body-map-context.html` — reads `body-region` frontmatter, picks front/back views |
| Shortcode version | `layouts/shortcodes/body-map-context.html` — wraps the partial for manual use |
| Called from | `layouts/_default/article.html:8` |
| Container layout | `custom-header.html:461-466` — `.body-map-context` float right, margin `0 0 1rem 1.5rem` |
| SVG size | `custom-header.html:468-470` — `.body-map-context svg` at `width: 5rem` |
| Faded regions | `custom-header.html:474-478` — `.body-map-context .body-region` uses `--BODY-OUTLINE-fill` |
| Highlighted regions | `custom-header.html:480-484` — `.body-map-context .body-region.is-highlighted` active fill + stroke |
| Outline opacity | `custom-header.html:486-488` — `.body-map-context .body-outline` at `opacity: 0.5` |
| Mobile (centered) | `custom-header.html:490-496` — `@media (max-width: 480px)` removes float, centers |
| JS: highlight logic | `layouts/partials/body-map-context.html:46-54` — adds `.is-highlighted` class to matching SVG IDs |

If the body diagram overlaps with borders or content, check:
- The float + margin at `custom-header.html:461-466`
- The h2 border-bottom at `custom-header.html:47-50`
- Content max-width at `custom-header.html:34-36` (`#body .padding` at `32rem`)

### Article body text
The main prose content area on non-home pages.

| What | Where |
|------|-------|
| Template | `layouts/_default/article.html` (wraps in `article.default`) |
| Content max-width | `custom-header.html:34-36` — `#body .padding` at `max-width: 32rem` |
| h2 border-bottom | `custom-header.html:47-50` — `#body h2` gets `1px solid` link-color border |
| Overflow control | `custom-header.html:29-31` — `#R-body-inner` overflow-x hidden |

### Exercise table shortcode
Auto-generated table listing child pages with JD number, title, and description.

| What | Where |
|------|-------|
| Shortcode | `layouts/shortcodes/exercise-table.html` — iterates `.Page.Pages.ByWeight` |
| Usage | `{{</* exercise-table */>}}` in any `_index.md` |
| Sort order | Page `weight` frontmatter (lower = higher) |
| JD number column | Uses `menuPre` from page frontmatter |


## Body Region Pages (`/body-region/*`)

### Region index (`/body-region/`)
The page listing all body regions with an interactive map.

| What | Where |
|------|-------|
| Template | `layouts/body-region/terms.html` — renders heading + body-map partial |
| Body map | Same as homepage body map (see above) |

### Individual region page (e.g., `/body-region/shoulders/`)
Shows a region-specific body graphic and grouped exercise listings.

| What | Where |
|------|-------|
| Template | `layouts/body-region/term.html` — full page layout |
| Region data | `data/body_regions.toml` — label, SVG ID, views, description |
| Body graphic | `layouts/body-region/term.html:16-41` — inline SVG + highlight JS (same pattern as body-map-context) |
| Section tabs | `layouts/body-region/term.html:80-94` — `.tab-panel` with `<details>` accordion |
| Tab styling | `custom-header.html:522-534` — `.tab-panel summary` and `.tab-panel details` |
| Exercise list items | `custom-header.html:499-520` — `.body-region-page-list`, `.body-region-page-item`, `.body-region-page-desc` |
| Section definitions | `layouts/body-region/term.html:50-57` — hardcoded list: Mobility, Warm-Up, Strength, Recovery, Pain Prescriptions, Concepts |

When there's only one active section, tabs are suppressed and it renders as a
plain heading + list (term.html:68-78).


## Sidebar

### Sidebar frame (width, border, collapse)

| What | Where |
|------|-------|
| Width/bounds | `custom-header.html:92-97` — `#R-sidebar` fit-content, min `14rem`, max `21rem` |
| Right border | `custom-header.html:96` — `border-right: 1px solid` |
| Responsive collapse | `custom-header.html:102-140` — `@media (max-width: 60rem)` hamburger mode |
| Header separator | `custom-header.html:143-145` — `#R-header-wrapper` border-bottom |
| JS: dynamic width sync | `custom-header.html:658-691` — ResizeObserver + MutationObserver sets `--INTERNAL-MENU-L-width` |

### Sidebar items (nav links)

| What | Where |
|------|-------|
| Spacing | `custom-header.html:148-151` — `#R-sidebar ul li` padding `0.1rem` |
| Font | `custom-header.html:154-158` — `#R-sidebar ul li a` weight 400, size `0.9rem` |
| Active indicator | `custom-header.html:161-163` — `#R-sidebar ul li.active > a` right border `3px solid` |
| JD number weight | `custom-header.html:166-168` — `.read-icon-link` at `font-weight: 600` |
| Touch target | `custom-header.html:247-251` — min-height `2rem`, flex align |
| Site title | `custom-header.html:83-90` — `#R-logo` font-size, nowrap, left-aligned |

### Sidebar footer (theme toggle + links)
The bottom section with Light/Auto/Dark toggle, Code of Conduct, and "Built with Hugo."

| What | Where |
|------|-------|
| Theme toggle template | `layouts/partials/sidebar/element/variantswitcher.html` — Relearn hidden select + custom button |
| Toggle button CSS | `custom-header.html:540-650` — `.toggle-color-scheme-button` and all `[data-scheme]` states |
| Toggle button layout | `custom-header.html:553-568` — pill shape, border, font |
| Icon wrapper | `custom-header.html:575-583` — `.icon-wrapper` 38x24px rounded track |
| Icon positions | `custom-header.html:586-594` — `.icon` absolute positioning, opacity/transform per state |
| Light state | `custom-header.html:607-614` — sun icon visible |
| Auto state | `custom-header.html:617-632` — half-circle icon, `translateX(6px)` |
| Dark state | `custom-header.html:635-650` — moon icon, `translateX(12px)` |
| JS: toggle cycling | `custom-header.html:762-804` — click handler cycles light/auto/dark, calls `relearn.changeVariant()` |
| Footer links | `layouts/partials/menu-footer.html` — Code of Conduct, Hugo link, Netlify link (inline styles) |
| Variant config | `hugo.toml` — `[[params.themeVariant]]` entries define the three variants |


## Color & Theming

### Light mode palette

| What | Where |
|------|-------|
| All variables | `assets/css/theme-mobility.css` |
| Key: bg `#F7F3EE`, text `#2A2520`, links `#B84A28` | |
| Body region fills | `--BODY-REGION-fill`, `-hover-fill`, `-active-fill` |
| Tag styling | `--TAG-BG-color` + arrow pseudo-element overrides |

### Dark mode palette

| What | Where |
|------|-------|
| All variables | `assets/css/theme-mobility-dark.css` |
| Key: bg `#1A1714`, text `#E8E2D8`, links `#D4734E` | |

### Syntax highlighting

| What | Where |
|------|-------|
| Chroma styles | `assets/css/chroma-mobility.css` — Nord theme |

### Chrome mobile address bar

| What | Where |
|------|-------|
| Meta tags | `custom-header.html:8-9` — `<meta name="theme-color">` |


## Global / Cross-cutting

### Content width

| What | Where |
|------|-------|
| Article pages | `custom-header.html:34-36` — `#body .padding` at `32rem` |
| Homepage elements | `custom-header.html:39-44` — `article.home > *` at `40rem` |
| Body map container | `custom-header.html:363` — `.body-map-container` at `36rem` |
| Inline TOC | `custom-header.html:178` — `.inline-toc` at `24rem` |

### Accessibility

| What | Where |
|------|-------|
| Focus outlines | `custom-header.html:220-227` — `:focus-visible` 3px solid |
| Skip-to-content | `custom-header.html:229-243` (CSS) + `custom-header.html:654` (HTML) |
| Touch targets | `custom-header.html:247-251` — sidebar links min-height `2rem` |
| Reduced motion | `custom-header.html:254-258` — `prefers-reduced-motion` |
| High contrast | `custom-header.html:345-352` — `forced-colors: active` |

### Footnotes

| What | Where |
|------|-------|
| Styling | `custom-header.html:300-341` — `.footnotes` border-top, smaller font, superscript refs |


## Quick Reference: File Purposes

| File | Role |
|------|------|
| `layouts/partials/custom-header.html` | All CSS + all JS. The big one. |
| `layouts/partials/content-header.html` | Tags, difficulty badge, reading time, inline TOC |
| `layouts/partials/body-map.html` | Homepage interactive body map |
| `layouts/partials/body-map-context.html` | Article-level small body graphic |
| `layouts/home/article.html` | Homepage template |
| `layouts/_default/article.html` | Default article page template |
| `layouts/body-region/term.html` | Individual body region page |
| `layouts/body-region/terms.html` | Body region index page |
| `layouts/partials/sidebar/element/variantswitcher.html` | Theme toggle button |
| `layouts/partials/menu-footer.html` | Sidebar footer links |
| `layouts/shortcodes/exercise-table.html` | Auto-generated exercise table |
| `layouts/shortcodes/body-map-context.html` | Manual body graphic shortcode |
| `assets/css/theme-mobility.css` | Light mode colors |
| `assets/css/theme-mobility-dark.css` | Dark mode colors |
| `assets/css/chroma-mobility.css` | Syntax highlighting |
| `static/svg/body-front.svg` | Front body SVG (polygon regions) |
| `static/svg/body-back.svg` | Back body SVG (polygon regions) |
| `data/body_regions.toml` | Region metadata (labels, IDs, views) |
| `hugo.toml` | Site config, theme variants, taxonomies, markup settings |
