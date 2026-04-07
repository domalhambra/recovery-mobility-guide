# Badwater Mobility — Site Maintenance Guide

How to add content, edit pages, and manage the structure of this Hugo site.

## How the site works

This is a Hugo static site using the Relearn theme. All content lives in Markdown files inside the `content/` folder. When you push changes to GitHub, Netlify automatically rebuilds and deploys the site. There is no CMS or database — everything is files.

**The flow:** Edit Markdown files locally, preview with `make dev`, push to GitHub, Netlify deploys.

---

## Quick reference

| Task | Command |
|------|---------|
| Start local preview | `make dev` |
| Build for production | `make build` |
| Clean build output | `make clean` |
| Live site | https://mobility-guide.netlify.app/ |

The local preview runs at `http://localhost:1313` and auto-refreshes when you save a file.

---

## Content structure

Content is organized by topic area, using a numbering system inspired by Johnny Decimal:

```
content/
  _index.md                     # Homepage
  mobility/                     # 10-19 — Mobility & joint health
    upper-body/                 #   11 — Shoulders, thoracic, wrists
    lower-body/                 #   12 — Hips, ankles, knees
    spine-and-core/             #   13 — Thoracic rotation, lumbar, neck
    cars/                       #   14 — Controlled articular rotations
    full-body/                  #   15 — Multi-region flows
    static-stretching/          #   16 — Sustained holds
  warm-up/                      # 20-29 — Warm-up & activation
    pre-shift/                  #   21
    pre-workout/                #   22
    sport-specific/             #   23
    activation-drills/          #   24
  strength/                     # 30-39 — Strength & movement
    upper-body/, lower-body/, full-body/,
    bodyweight/, kettlebell-sandbag/,
    cycling/, endurance-cardio/
  recovery/                     # 40-49 — Recovery & restoration
    post-shift/                 #   41
    post-workout/               #   42
    myofascial-release/         #   43
    breathwork/                 #   44
  pain-prescriptions/           # 50-59 — Pain protocols by region
    shoulder/, lower-back/, neck-headache/,
    hip-glute/, knee-shin/, ankle-foot/,
    wrist-forearm/
  concepts/                     # 60-69 — Reference & explainer pages
```

**The rule:** Every folder must have an `_index.md` file, or it won't appear in the sidebar.

---

## Adding a new exercise page

### 1. Pick the right folder

Find the section and subcategory where the exercise belongs. For example, a new hip mobilization goes in `content/mobility/lower-body/`.

### 2. Create the file

Name the file using lowercase words separated by hyphens. The filename becomes the URL slug.

```
content/mobility/lower-body/banded-hip-distraction.md
```

This creates the URL: `mobility-guide.netlify.app/mobility/lower-body/banded-hip-distraction/`

### 3. Write the front matter

Every page starts with a YAML front matter block between `---` lines:

```yaml
---
title: "Banded Hip Distraction"
description: "Band-assisted hip mobilization that improves squat depth and hip flexion range."
menuPre: "12.07 "
weight: 70
tags: ["hips", "flexibility", "intermediate", "resistance-band"]
---
```

Here's what each field does:

| Field | What it does | Format |
|-------|-------------|--------|
| `title` | Page heading and sidebar label | Quoted string |
| `description` | One sentence for SEO and search | Quoted string |
| `menuPre` | JD number shown before the title in the sidebar | `"XX.XX "` — include the trailing space |
| `weight` | Controls sort order in the sidebar (lower = higher) | Number, use increments of 10 |
| `tags` | Used for filtering, search, and auto-generated badges | Array of strings (see tag guide below) |

### 4. Write the content

Here's the standard structure most exercise pages follow:

```markdown
---
title: "Exercise Name"
description: "One-sentence description."
menuPre: "12.07 "
weight: 70
tags: ["hips", "flexibility", "intermediate", "resistance-band"]
---

Brief intro paragraph explaining what this exercise does and why it matters.

{{</* tabs */>}}
{{% tab title="Instructions" %}}

## Setup

1. Step-by-step instructions...

## Coaching Cues

**What to feel:**
- ...

**Common mistakes:**
- ...

{{% /tab %}}
{{% tab title="Media" %}}

*Video and animated demos coming soon.*

{{% /tab %}}
{{</* /tabs */>}}

## Programming

| Parameter | Recommendation |
|-----------|---------------|
| **Reps** | ... |
| **Sets** | ... |
| **Frequency** | ... |
| **When to do it** | ... |

## Progressions

1. **Beginner:** ...
2. **Intermediate:** ...
3. **Advanced:** ...
```

This structure isn't mandatory, but it keeps the site consistent. Routine/protocol pages use a different layout (sequence tables with cross-references instead of tabs).

---

## Adding videos

Most exercise pages have a Media tab. To embed a video, replace the placeholder text with a shortcode.

### YouTube

Grab the video ID from the URL — it's the part after `v=` or after `youtu.be/`.

```
https://www.youtube.com/watch?v=ZcC44QpmK5w
                                 ^^^^^^^^^^^^ this is the ID
```

Then use Hugo's built-in `youtube` shortcode:

```markdown
{{% tab title="Media" %}}

{{</* youtube "ZcC44QpmK5w" */>}}

{{% /tab %}}
```

That's it. Hugo generates a responsive, privacy-enhanced iframe automatically. No raw HTML needed.

### Vimeo

Same idea, different shortcode. The ID is the number at the end of the Vimeo URL.

```markdown
{{</* vimeo "123456789" */>}}
```

### Multiple videos on one page

Stack them with a label above each one:

```markdown
{{% tab title="Media" %}}

### Front View
{{</* youtube "ZcC44QpmK5w" */>}}

### Side View
{{</* youtube "EVcnudMqQCE" */>}}

{{% /tab %}}
```

### Replacing the placeholder

Most pages currently have this placeholder in the Media tab:

```markdown
*Video and animated demos coming soon.*
```

Delete that line and drop in the shortcode. The page already has the tab structure — you're just swapping the contents.

---

## Tag guide

Tags serve three purposes: search filtering, difficulty badges (auto-generated), and content grouping. Include at least one from each relevant category:

**Body region:** hips, knees, ankles, shoulders, thoracic, spine, upper-back, neck, glutes, wrist-forearm

**Modality:** flexibility, strength, activation, myofascial-release, foam-rolling, breathing, nerve-glide

**Difficulty:** beginner, intermediate, advanced
- These auto-generate a colored badge on the page (green, yellow, red).

**Equipment** (when applicable): no-equipment, foam-roller, lacrosse-ball, resistance-band, barbell, kettlebell

---

## Adding a new section or subcategory

If you need a new folder (say, a new subcategory under mobility):

### 1. Create the folder and its `_index.md`

```
mkdir content/mobility/new-category/
```

Then create `content/mobility/new-category/_index.md`:

```yaml
---
title: "New Category Name"
menuPre: "17 "
weight: 70
description: "One sentence describing this category."
---

Intro paragraph for the section landing page.
```

For top-level sections (area pages like `mobility/` or `recovery/`), the `_index.md` also includes `alwaysopen: true` so its children show expanded in the sidebar, and `menuPre` uses the range format (`"10-19 "`).

### 2. Add exercise pages inside the folder

Follow the exercise page instructions above. Each page goes directly in the new folder.

---

## The JD numbering system

The `menuPre` field controls the number shown in the sidebar. The numbering follows this pattern:

- **Area pages** (top-level sections): `"10-19 "`, `"20-29 "`, `"40-49 "`, etc.
- **Category pages** (subcategories): `"11 "`, `"12 "`, `"21 "`, `"43 "`, etc.
- **Individual pages** (exercises): `"12.01 "`, `"12.02 "`, `"43.09 "`, etc.

When adding a new exercise to an existing category, look at the existing `menuPre` numbers in that folder and pick the next available one. The number must be unique within its category.

Always include the trailing space after the number — it separates the number from the title in the sidebar.

---

## Editing existing pages

Open the `.md` file, make your changes, and save. The local dev server (`make dev`) will auto-refresh so you can see the result immediately.

Common edits:
- **Fix text:** Edit the Markdown content below the front matter.
- **Change sort order:** Adjust the `weight` value. Lower numbers appear first.
- **Update tags:** Modify the `tags` array in the front matter.
- **Change the sidebar label:** Edit `title`. The sidebar uses the title field.
- **Mark as draft:** Add `draft: true` to the front matter. The page will be hidden in production but visible with `make dev`.

---

## Cross-referencing other pages

To link to another page on the site, use Hugo's `relref` shortcode:

```markdown
[Pigeon Stretch]({{</* relref "/mobility/lower-body/pigeon-stretch" */>}})
```

This generates the correct URL regardless of where the linking page lives. Always use the path from the content root (starting with `/`).

---

## Shortcodes used on this site

Hugo shortcodes add interactive elements. Here are the ones this site uses:

### Tabs (Instructions / Media pattern)

```markdown
{{</* tabs */>}}
{{% tab title="Instructions" %}}
Content here (Markdown works).
{{% /tab %}}
{{% tab title="Media" %}}
Content here.
{{% /tab %}}
{{</* /tabs */>}}
```

Note the difference: outer `tabs` uses angle brackets `< >`, inner `tab` uses percent signs `% %`. This is required for Markdown rendering inside tabs.

### Notice boxes

```markdown
{{% notice tip %}}
Helpful tip content.
{{% /notice %}}

{{% notice warning %}}
Warning content.
{{% /notice %}}
```

---

## Publishing workflow

### Preview locally

```bash
make dev
```

Open `http://localhost:1313` and check your changes. Draft pages (with `draft: true`) only appear in this local preview.

### Deploy to production

```bash
git add content/path/to/your-file.md
git commit -m "Add banded hip distraction exercise"
git push
```

Netlify watches the GitHub repo and automatically builds and deploys on every push. The build takes about 30 seconds. You can check build status at your Netlify dashboard.

### What Netlify runs

The build command (from `netlify.toml`) is:

```
hugo --environment production && npx -y pagefind --site public
```

This builds the site with Hugo, then runs Pagefind to generate the search index. If either step fails, the deploy is skipped and the previous version stays live.

---

## Troubleshooting

**Page doesn't appear in the sidebar:**
- Make sure the folder has an `_index.md` file.
- Check that the page doesn't have `draft: true` in production.
- Verify the `weight` value — a very high number pushes it to the bottom.

**Sidebar shows wrong order:**
- Sort order is controlled by `weight`. Lower numbers appear first. Use increments of 10 so you can insert pages between existing ones later.

**Build fails on Netlify:**
- Check the deploy log in your Netlify dashboard. Common causes: malformed front matter (missing closing `---`), broken shortcode syntax, or a `relref` pointing to a page that doesn't exist.

**Search doesn't find new content:**
- Pagefind rebuilds the search index at deploy time. If you just pushed, wait for the build to finish. Locally, search isn't available with `make dev` — it only works after `make build`.

**Changes don't appear on the live site:**
- Confirm the push reached GitHub. Then check Netlify for a successful deploy. Browser caching can also delay updates — try a hard refresh.
