# YouTube Video Integration — Design Spec

**Date:** 2026-04-27
**Status:** Approved

## Goal

Prove the visual concept of embedding YouTube videos in exercise pages by populating the existing Media tab on a representative handful of pages.

## Scope

6 exercise pages across 4 sections:

| Exercise | File | Section |
|----------|------|---------|
| 90/90 Hip Stretch | `content/mobility/lower-body/90-90-stretch.md` | Lower body |
| Couch Stretch | `content/mobility/lower-body/couch-stretch.md` | Lower body |
| Hip CARs | `content/mobility/cars/hip-cars.md` | CARs |
| Cat-Cow | `content/mobility/spine-and-core/cat-cow.md` | Spine/core — note: `cat-cow-stretch.md` and `cat-cow-spinal-rolls.md` exist in the same directory; edit only `cat-cow.md` |
| Bird Dog | `content/mobility/spine-and-core/bird-dog.md` | Spine/core |
| Shoulder Dislocates | `content/mobility/upper-body/shoulder-dislocates.md` | Upper body |

## Rendering

Each page's Media tab currently contains only:

```
*Video and animated demos coming soon.*
```

Replace that line with Hugo's built-in youtube shortcode:

```
{{< youtube VIDEO_ID >}}
```

Nesting `{{< youtube >}}` inside a `{{% tab %}}` block works as expected in Hugo — no syntax changes required. Hugo outputs a responsive iframe. No new code or shortcodes required.

## Video Curation

Web search each exercise by name to find the best available YouTube video. Selection criteria:

- Clear demonstration of the exercise with correct form
- Good production quality (stable camera, visible body position)
- Authoritative source (physio/PT channel, established coach)

Video ID is extracted from the YouTube URL (`v=` parameter or short URL suffix).

If no video meets all three criteria for a given exercise, leave the placeholder text in place for that page rather than shipping a low-quality embed.

## Verification

Run `make dev` and open each updated page in browser. Confirm:

- Embed renders in the Media tab (not the Instructions tab)
- Video is responsive at normal and narrow widths
- No layout breakage on adjacent tabs or surrounding content
- Video plays in the iframe (no "Watch on YouTube" or "Video unavailable" message)

Geographic embed restrictions (videos blocked in certain regions) are not tested in this PoC — verification covers the implementer's local environment only.

## Out of Scope

- Front matter `youtube` field (not needed for this PoC)
- Custom wrapper shortcode with attribution
- Lazy-load / click-to-play optimization
- Populating all exercise pages (this is a PoC only)
