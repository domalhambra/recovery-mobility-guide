# Recovery & Mobility Guide — Project Context

## What this is
A static Hugo site using the Relearn theme, hosted on Netlify. It's a reference
library for recovery and mobility exercises, organized by body region.

## Stack
- Hugo (extended) with Hugo Relearn Theme (git submodule in themes/)
- Pagefind for client-side search
- Netlify for hosting (connected via MCP server)
- GitHub repo for version control

## Content structure
Content lives in content/, organized by body region:
- lower-body/ (hips/, knees/, ankles/)
- upper-body/ (shoulders/, thoracic/)
- spine-and-core/
- routines/ (pre-built exercise sequences)
- concepts/ (explanatory reference pages)

Every folder needs an _index.md to register as a sidebar section.

## Conventions
- Sidebar ordering uses `weight` in front matter, increments of 10
- Lower weight = higher position in sidebar
- Exercise pages use this front matter template:
  ---
  title: "Exercise Name"
  weight: 10
  tags: ["body-region", "modality", "difficulty"]
  ---
- Modality tags: flexibility, strength, foam-rolling, breathing, nerve-glide
- Difficulty tags: beginner, intermediate, advanced

## Build commands
- Local dev: hugo server --buildDrafts
- Production build: hugo && npx -y pagefind --site public
- Netlify build command: hugo --environment production && npx -y pagefind --site public

## Color scheme
Custom variant file at assets/css/theme-mobility.css
Using a green palette (recovery/health feel) with CSS variables.
The variant name in hugo.toml is "mobility".

## Key files
- hugo.toml — site configuration
- assets/css/theme-mobility.css — custom color scheme
- layouts/partials/logo.html — site logo override
- layouts/partials/custom-header.html — CSS tweaks
- content/ — all site content (Markdown)
- netlify.toml — Netlify build configuration
- Makefile — local build shortcuts
