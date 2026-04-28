# YouTube Video Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Media tab placeholder text on 6 exercise pages with live YouTube embeds to prove the visual concept.

**Architecture:** Each exercise page's "Media" tab contains the text `*Video and animated demos coming soon.*` — replace it with Hugo's built-in `{{< youtube VIDEO_ID >}}` shortcode. No new files, no template changes, no front matter fields. Verify each page renders correctly in the local dev server before committing.

**Tech Stack:** Hugo (extended, v0.157.0+), Hugo Relearn Theme, `make dev` for local preview on :1313

---

## Video ID Reference

| Exercise | File | YouTube ID |
|----------|------|-----------|
| 90/90 Hip Stretch | `content/mobility/lower-body/90-90-stretch.md` | `t4Zz6-aG8Iw` |
| Couch Stretch | `content/mobility/lower-body/couch-stretch.md` | `WKo4APrwfXQ` |
| Hip CARs | `content/mobility/cars/hip-cars.md` | `5kM-o61Z14I` |
| Cat-Cow | `content/mobility/spine-and-core/cat-cow.md` | `xyNwxiuERXc` |
| Bird Dog | `content/mobility/spine-and-core/bird-dog.md` | `ZdAHe9_HeEw` |
| Shoulder Dislocates | `content/mobility/upper-body/shoulder-dislocates.md` | `WXP05GGFkrU` |

> Note: Three cat-cow files exist in `content/mobility/spine-and-core/` — edit only `cat-cow.md`, not `cat-cow-stretch.md` or `cat-cow-spinal-rolls.md`.

---

## Task 1: Update Lower-Body Pages

**Files:**
- Modify: `content/mobility/lower-body/90-90-stretch.md`
- Modify: `content/mobility/lower-body/couch-stretch.md`

- [ ] **Step 1: Open 90-90-stretch.md and locate the Media tab**

  Find this block (inside the `{{% tab title="Media" %}}` section):
  ```
  *Video and animated demos coming soon.*
  ```

- [ ] **Step 2: Replace the placeholder with the YouTube shortcode**

  Replace the line above with:
  ```
  {{< youtube t4Zz6-aG8Iw >}}
  ```

  The full Media tab section should now look like:
  ```
  {{% tab title="Media" %}}

  {{< youtube t4Zz6-aG8Iw >}}

  {{% /tab %}}
  ```

- [ ] **Step 3: Repeat for couch-stretch.md**

  Same location, replace placeholder with:
  ```
  {{< youtube WKo4APrwfXQ >}}
  ```

---

## Task 2: Update CARs Page

**Files:**
- Modify: `content/mobility/cars/hip-cars.md`

- [ ] **Step 1: Open hip-cars.md and locate the Media tab**

  Find:
  ```
  *Video and animated demos coming soon.*
  ```

- [ ] **Step 2: Replace with the YouTube shortcode**

  ```
  {{< youtube 5kM-o61Z14I >}}
  ```

---

## Task 3: Update Spine-and-Core Pages

**Files:**
- Modify: `content/mobility/spine-and-core/cat-cow.md` (not cat-cow-stretch.md or cat-cow-spinal-rolls.md)
- Modify: `content/mobility/spine-and-core/bird-dog.md`

- [ ] **Step 1: Open cat-cow.md and locate the Media tab**

  Find:
  ```
  *Video and animated demos coming soon.*
  ```

- [ ] **Step 2: Replace with the YouTube shortcode**

  ```
  {{< youtube xyNwxiuERXc >}}
  ```

- [ ] **Step 3: Open bird-dog.md and locate the Media tab**

  Same placeholder, replace with:
  ```
  {{< youtube ZdAHe9_HeEw >}}
  ```

---

## Task 4: Update Upper-Body Page

**Files:**
- Modify: `content/mobility/upper-body/shoulder-dislocates.md`

- [ ] **Step 1: Open shoulder-dislocates.md and locate the Media tab**

  Find:
  ```
  *Video and animated demos coming soon.*
  ```

- [ ] **Step 2: Replace with the YouTube shortcode**

  ```
  {{< youtube WXP05GGFkrU >}}
  ```

---

## Task 5: Verify in Browser

- [ ] **Step 1: Start the dev server**

  ```bash
  make dev
  ```

  Expected: Hugo server running at http://localhost:1313

- [ ] **Step 2: Open each updated page and click the Media tab**

  Visit each of these URLs and click the "Media" tab:
  - http://localhost:1313/mobility/lower-body/90-90-stretch/
  - http://localhost:1313/mobility/lower-body/couch-stretch/
  - http://localhost:1313/mobility/cars/hip-cars/
  - http://localhost:1313/mobility/spine-and-core/cat-cow/
  - http://localhost:1313/mobility/spine-and-core/bird-dog/
  - http://localhost:1313/mobility/upper-body/shoulder-dislocates/

- [ ] **Step 3: Confirm for each page**

  - Embed renders in the Media tab (not the Instructions tab)
  - Video plays in the iframe (no "Watch on YouTube" or "Video unavailable" message)
  - Video is responsive — resize the browser window to a narrow width and confirm the embed scales
  - No layout breakage on adjacent tabs or surrounding content
  - If a video shows "Video unavailable" or blocks embedding, revert that page to the placeholder text and note it — don't leave a broken embed

- [ ] **Step 4: Stop the dev server**

  `Ctrl+C`

---

## Task 6: Commit

- [ ] **Step 1: Stage the 6 modified files**

  ```bash
  git add content/mobility/lower-body/90-90-stretch.md \
          content/mobility/lower-body/couch-stretch.md \
          content/mobility/cars/hip-cars.md \
          content/mobility/spine-and-core/cat-cow.md \
          content/mobility/spine-and-core/bird-dog.md \
          content/mobility/upper-body/shoulder-dislocates.md
  ```

- [ ] **Step 2: Commit**

  ```bash
  git commit -m "Add YouTube video embeds to 6 exercise Media tabs (PoC)"
  ```

- [ ] **Step 3: Verify clean state**

  ```bash
  git status
  ```

  Expected: `nothing to commit, working tree clean`
