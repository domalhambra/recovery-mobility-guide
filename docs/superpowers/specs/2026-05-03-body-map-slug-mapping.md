# Body Map Slug Mapping — Lotus Docs Port

**Status:** Spike output (Task 1 of `2026-05-03-lotus-docs-port.md`)
**Date:** 2026-05-03
**Author:** Spike research pass
**Gates:** Tasks 9, 10, 11 (SVG generation and integration)

## Purpose

Map the 14 body region slugs used in `data/body_regions.toml` to the path slugs published by [`HichamELBSI/react-native-body-highlighter`](https://github.com/HichamELBSI/react-native-body-highlighter) (MIT). This document is the source of truth the SVG-build tasks (10 and 11) will follow when extracting paths and assembling the front/back composite SVGs that drive the homepage body map.

The current homepage body map uses geometric polygons extracted from `react-body-highlighter` (the web sibling). The port is upgrading to the more anatomically polished `react-native-body-highlighter` paths.

## Source files

Pulled from `main` of the upstream repo and saved to `/tmp/body-map-spike/`:

- `bodyFront.ts` — 318 lines, 19 unique slugs
- `bodyBack.ts` — 261 lines, 16 unique slugs

Each entry is a `BodyPart` with shape:

```ts
{
  slug: string,
  color: string,
  path: { left?: string[], right?: string[] }
}
```

Some slugs (e.g. `chest`) only have left+right symmetric paths; others (e.g. `obliques`, `abs`) have several path strings per side that compose the region.

## Full source-slug inventory

### Front (bodyFront.ts) — 19 slugs
`abs`, `adductors`, `ankles`, `biceps`, `calves`, `chest`, `deltoids`, `feet`, `forearm`, `hair`, `hands`, `head`, `knees`, `neck`, `obliques`, `quadriceps`, `tibialis`, `trapezius`, `triceps`

### Back (bodyBack.ts) — 16 slugs
`adductors`, `ankles`, `calves`, `deltoids`, `feet`, `forearm`, `gluteal`, `hair`, `hamstring`, `hands`, `head`, `lower-back`, `neck`, `trapezius`, `triceps`, `upper-back`

### Slugs that appear on both views
`adductors`, `ankles`, `calves`, `deltoids`, `feet`, `forearm`, `hair`, `hands`, `head`, `neck`, `trapezius`, `triceps`

### Notable absences from the source
- No `hips` slug. The pelvic region is bounded by `abs` (front), `obliques` (front), `adductors` (front+back), and `gluteal` (back). There is no path that cleanly represents "hips" as a distinct anatomical zone.
- No `lats`. The mid/upper back posterior surface is covered by `upper-back`.
- No separate `wrists` or `elbows`. The arms are split into `biceps`/`triceps`/`forearm` and `hands`.
- No `shins` slug. There is `tibialis` on the front, which is the anatomical name for the shin muscle.
- No `quads` slug — it's named `quadriceps`.

## Our 14 target slugs

Confirmed against `data/body_regions.toml`:

`neck`, `shoulders`, `chest`, `arms`, `core`, `hips`, `quads`, `ankles`, `upper-back`, `lower-back`, `glutes`, `hamstrings`, `calves`, `feet`

## Slug map

| Our slug | Source slug(s) | View(s) | Notes |
|---|---|---|---|
| `neck` | `neck` | front + back | 1:1. Source draws neck on both views. Our toml says `views = ["front", "back"]`. Match. |
| `shoulders` | `deltoids` | front + back | 1:1. Source uses `deltoids` on both views. Our toml says `views = ["front", "back"]`. Match. |
| `chest` | `chest` | front | 1:1. Front only — matches our toml. |
| `arms` | `biceps` + `triceps` + `forearm` + `hands` | front + back | Composite: `biceps` (front), `triceps` (front + back), `forearm` (front + back), `hands` (front + back). Our region label is "Arms, Wrists & Hands" so including `hands` is on-spec. |
| `core` | `abs` + `obliques` | front | Composite. Both source slugs are front-only. Matches our `views = ["front"]`. |
| `hips` | **GAP — synthesize** | front | See gap-fill section below. |
| `quads` | `quadriceps` + `knees` | front | Composite. Source slug is `quadriceps` (renamed in our toml to `quads`). Our toml `tags = ["quadriceps", "knees"]` so including `knees` is on-spec. Front only. |
| `ankles` | `ankles` + `tibialis` | front + back | Source has `ankles` on both views. Adding `tibialis` (front shin) gives the region anatomical sense for the "Shins & Ankles" label. Our toml currently says `views = ["front"]` only, but source supports back too — see "Concerns" below. |
| `upper-back` | `upper-back` + `trapezius` | back | Composite. `trapezius` exists on both views; for the "Upper Back" region we use only the back-view trapezius path. |
| `lower-back` | `lower-back` | back | 1:1. Back only — matches our toml. |
| `glutes` | `gluteal` | back | 1:1 with rename (source uses singular `gluteal`). Back only — matches our toml. |
| `hamstrings` | `hamstring` | back | 1:1 with rename (source uses singular `hamstring`). Back only — matches our toml. |
| `calves` | `calves` | back | Source has `calves` on both views, but we only render back for this region (matches our toml). |
| `feet` | `feet` | front | Source has `feet` on both views. Our toml says `views = ["front"]` so we use the front path only. |

## Gap-fill decisions

### `hips` — SYNTHESIZE

**Problem:** No `hips` slug exists in either source file. The hip joint area is anatomically bounded by `abs` (lower front), `obliques` (lateral front), `adductors` (medial upper-leg, both views), and `gluteal` (posterior, back).

**Decision:** Synthesize a hip region polygon for the front view only, occupying the iliac/greater-trochanter zone — roughly the area between the bottom of `obliques`, the top of `adductors`, and the top of `quadriceps`. Use a simple closed path (4-6 anchor points) painted in the same fill style as the other regions. Place it as a separate `<path>` with `id="region-hips"` so it participates in the existing hover/click behavior.

**Rationale:** The hips region is a high-value content area (hip flexor mobility is core to firefighter recovery). Removing it from `body_regions.toml` would lose substantial existing content references. A synthesized polygon over the right anatomical zone is acceptable for an interactive map (it doesn't need to be a perfect anatomical illustration — it's a click target labeled "Hips").

**Implementation note for Task 10/11:** The synthesized path should be drawn AFTER `obliques`/`adductors` in z-order, or it will hide behind them. Test layering carefully. Pick coordinates by inspecting the `obliques`/`adductors` path bounding boxes in the assembled SVG.

### Other slugs

All other 13 slugs have direct or composite source mappings. No additional synthesis required.

## View parity check

Our toml currently asserts these view assignments:

| Region | Toml `views` | Source supports |
|---|---|---|
| neck | front + back | front + back |
| shoulders | front + back | front + back (deltoids) |
| chest | front | front only |
| arms | front + back | front + back |
| core | front | front only |
| hips | front | n/a (synthesized) |
| quads | front | front only |
| ankles | front | **front + back** |
| upper-back | back | back only |
| lower-back | back | back only |
| glutes | back | back only |
| hamstrings | back | back only |
| calves | back | **front + back** (front exists but we don't use it) |
| feet | front | **front + back** (back exists but we don't use it) |

**Three regions where source has more views than we use:** `ankles` (back ankle exists), `calves` (front calf exists — actually it's the calf wrap visible from the side via `tibialis`), `feet` (back of feet exists).

**Recommendation for Task 10/11:** Honor the `views` field in `body_regions.toml` as the source of truth — only render paths for views the toml says the region appears on. The extra source paths are available if Dom later wants to expand a region's visibility.

## Sanity check (Step 6)

Pulled the `chest.path.left` string from `bodyFront.ts` and wrapped it in a minimal SVG at `/tmp/body-map-spike/test-chest.svg`. Confirmed the `d` attribute starts with `M` (move-to) — clean, well-formed SVG path data. Coordinates are in a ~600x800 viewBox space (chest centered around x=300, y=400). The path uses `M`, `c`, `q`, `z` commands — all standard SVG path syntax that any SVG renderer handles natively.

## Concerns and notes for Task 10/11

1. **Multiple paths per region.** `obliques` has 8+ separate path strings on each side. The implementer should concatenate all path strings within a slug's `left`/`right` arrays into a single `<path>` element OR emit them as a `<g>` group with the region's `id` on the group, so hover/click handlers fire on the whole region. Group is cleaner.

2. **Composite regions.** Five of our slugs (`arms`, `core`, `quads`, `upper-back`, `ankles`) are composites of multiple source slugs. These MUST be rendered as a `<g id="region-arms">` group containing all sub-paths, not as individual paths. The existing JS hover/click code targets `id="region-{slug}"`.

3. **Left/right symmetry.** Every source path object has `left` and/or `right` arrays. Both must be included in the composite group for symmetric regions.

4. **Color attribute.** Source paths have a `color: "#3f3f3f"` field. Ignore it — our CSS theme controls fill via `[data-region]` or `id` selectors. Strip the color when generating the final SVG.

5. **viewBox.** Inspect both source files' top-level viewBox/width/height (if present) when assembling the final composite SVGs. The path coordinates are tuned to a specific viewBox; the wrapping `<svg>` element must match. (The TS files only export the path data — viewBox is set in the React component. Look at the upstream React component or the rendered output for canonical viewBox values.)

6. **Hips synthesis review.** Once synthesized, the hips polygon should be eyeballed by Dom before the port lands. It's the only invented geometry in the map and it's worth a sanity check.

7. **Z-order.** Larger regions (chest, abs) tend to be drawn first; smaller overlapping regions (obliques, hips synthesis) on top. Match the source ordering when extracting, and slot the synthesized hips after `obliques`/`adductors`.

## Files produced by this spike

- `/tmp/body-map-spike/bodyFront.ts` — source download
- `/tmp/body-map-spike/bodyBack.ts` — source download
- `/tmp/body-map-spike/front-slugs.txt` — sorted slug list (front)
- `/tmp/body-map-spike/back-slugs.txt` — sorted slug list (back)
- `/tmp/body-map-spike/test-chest.svg` — sanity-extracted single path

These are scratch artifacts in `/tmp` and won't be committed. The mapping doc you're reading is the durable output.
