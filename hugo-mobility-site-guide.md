# Building a Recovery & Mobility Site with Hugo

A guide to creating a clean, fast, searchable documentation-style site for mobility exercises, modeled after johnnydecimal.com's approach. Optimized for Claude Code as the primary build tool.

---

## The Big Picture

You're building a static site. No database, no server-side code, no Notion dependency. Hugo takes your Markdown files, runs them through templates, and outputs plain HTML/CSS/JS. Netlify hosts those files for free and rebuilds automatically when you push to GitHub. Every page loads instantly because there's nothing to compute at request time.

The stack:

- Hugo — static site generator (written in Go, absurdly fast)
- Hugo Relearn Theme — documentation theme with nested sidebar navigation built in
- Pagefind — client-side static search (indexes at build time, searches in the browser)
- Netlify — free hosting with automatic builds on push
- Claude Code — scaffolds, configures, creates content, and deploys everything

---

## Phase 0: Prerequisites (the only manual steps)

These are things you need installed before Claude Code can take over. Run each in your terminal.

### Install Homebrew (if you don't have it)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Install Hugo, Git, Node.js

```bash
brew install hugo git node
```

Verify Hugo is the extended version (Homebrew does this by default):

```bash
hugo version
```

You should see "extended" in the output. The Relearn theme needs SCSS support from the extended build.

### Verify Node.js is version 22+

The Netlify MCP server requires Node 22 or higher.

```bash
node --version
```

If you're below 22, upgrade:

```bash
brew upgrade node
```

Or if you use nvm:

```bash
nvm install 22 && nvm use 22
```

### Install the Netlify CLI

```bash
npm install -g netlify-cli
```

This lets the Netlify MCP server use CLI commands directly when managing your site.

### Install Claude Code (if you haven't already)

```bash
npm install -g @anthropic-ai/claude-code
```

---

## Phase 1: Wire Up the Netlify MCP Server

This gives Claude Code the ability to create Netlify projects, set environment variables, trigger deploys, and manage your site without you ever opening the Netlify dashboard.

### Add the MCP server to Claude Code

```bash
claude mcp add-json "netlify" '{"command":"npx","args":["-y","@netlify/mcp"]}'
```

This registers the server at user scope by default, meaning it's available across all your projects.

### Authenticate with Netlify

When Claude Code first tries to use the Netlify MCP server, it will prompt you to authenticate through the Netlify CLI. If that flow gives you trouble, create a Personal Access Token as a fallback:

1. Go to the Netlify dashboard
2. Click your user icon (bottom left) > User settings > OAuth > New access token
3. Copy the token
4. Re-add the MCP server with the token:

```bash
claude mcp add-json "netlify" '{"command":"npx","args":["-y","@netlify/mcp"],"env":{"NETLIFY_PERSONAL_ACCESS_TOKEN":"your-token-here"}}'
```

Do not commit this token to any repo. Once the auth flow stabilizes, remove it from the config and rely on the CLI auth instead.

### Verify it works

Start Claude Code and ask it to list your Netlify sites. If it responds with your account info, the MCP connection is live.

---

## Phase 2: Create the Project

From here on, everything happens inside Claude Code. Open a terminal, navigate to where you want the project to live, and start a session:

```bash
mkdir mobility-guide && cd mobility-guide
claude
```

### Give Claude Code the project context

Save the following as `CLAUDE.md` in the project root. Claude Code reads this file automatically at the start of every session:

```markdown
This is a Hugo static site for recovery and mobility exercises using the Relearn theme.

## Stack
- Hugo (extended) with hugo-theme-relearn as a git submodule in themes/
- Pagefind for client-side search
- Netlify for hosting (use the Netlify MCP server for all deployment tasks)
- GitHub repo for version control

## Project Structure
- Content lives in content/, organized by body region
- Every folder needs an _index.md to register as a sidebar section
- Use weight values in increments of 10 for sidebar ordering (lower = higher)
- Front matter format: title, weight, tags (array), optional description

## Content Hierarchy
- Top-level sections: lower-body, upper-body, spine-and-core, routines, concepts
- Each section has subsections by specific area (hips, knees, ankles, etc.)
- Leaf pages are individual exercises or concepts

## Build Commands
- Local dev: hugo server --buildDrafts
- Production build: hugo && npx -y pagefind --site public
- Clean: rm -rf public

## Style
- Custom color variant in assets/css/theme-mobility.css
- System font stack (no Google Fonts)
- Color palette: earthy greens and warm neutrals

## Netlify Config
- Build command: hugo --environment production && npx -y pagefind --site public
- Publish directory: public
- Environment variables: HUGO_VERSION (match local), NODE_VERSION=22
```

### What to tell Claude Code

Here is the sequence of prompts that will scaffold the entire project. Give them one at a time so you can review each result before moving on.

**Prompt 1: Initialize the Hugo site and theme**

> Initialize a new Hugo site in the current directory. Add hugo-theme-relearn as a git submodule. Create a hugo.toml configured for the Relearn theme with: clean URLs, search output formats enabled (HTML, RSS, SEARCH, SEARCHPAGE), sidebar sections collapsed by default (alwaysopen = false), system font stack, and the color variant set to "mobility". Set the site title to "Recovery & Mobility Guide".

**Prompt 2: Create the content structure**

> Create the full content directory structure with _index.md files for each section and subsection. Use this hierarchy:
>
> - lower-body (weight 10): hips, knees, ankles
> - upper-body (weight 20): shoulders, thoracic, wrists-and-elbows
> - spine-and-core (weight 30): lumbar, core-stability
> - routines (weight 40): morning-flow, post-workout, desk-worker-reset
> - concepts (weight 50): foam-rolling-basics, progressive-overload-for-mobility, when-to-stretch-vs-strengthen
>
> Each section _index.md should have a one-sentence description. Each leaf page under routines and concepts should have title, weight, and relevant tags. For the exercise subsections (hips, knees, etc.), create 2-3 stub exercise pages each with front matter only (I'll fill in the content later).

**Prompt 3: Create the custom color variant**

> Create assets/css/theme-mobility.css with a custom Relearn color variant. Use an earthy green palette: dark forest green for the sidebar header (#1a5632), lighter sage for sidebar background (#f0f7f3), warm charcoal for body text (#2d3436), and muted green for links and accents (#1a7a4c). Include all the standard Relearn CSS variable overrides for MAIN-*, MENU-*, and CODE-* variables.

**Prompt 4: Add build tooling and Netlify config**

> Create a Makefile with targets for: dev (hugo server with drafts), build (hugo then pagefind), and clean (rm -rf public). Also create a netlify.toml file with the build command set to "hugo --environment production && npx -y pagefind --site public", publish directory "public", and environment variables for HUGO_VERSION (check my local version) and NODE_VERSION=22.

**Prompt 5: Create a sample exercise page**

> Write a complete exercise page for content/lower-body/hips/90-90-stretch.md. Include: an overview of what the exercise targets, detailed setup instructions, coaching cues (what to feel, common mistakes), programming recommendations (hold times, frequency, progressions), and tags for hips, flexibility, and beginner. Use Relearn notice shortcodes for a tip box about breathing and a warning box about knee pain. This page will serve as the template for all future exercise pages.

**Prompt 6: Style tweaks**

> Create layouts/partials/custom-header.html with CSS that: sets max content width to 50rem, adds a subtle bottom border to h2 elements using the link color variable, and increases line-height on body text slightly for readability.

**Prompt 7: Set up Git and deploy**

> Initialize a git repo, create a .gitignore (include public/, resources/, .hugo_build.lock, node_modules/, .DS_Store), make the initial commit, then use the Netlify MCP server to: create a new Netlify site called "mobility-guide", set the HUGO_VERSION environment variable to match my local Hugo version, set NODE_VERSION to 22, and trigger the first deploy.

At this point your site should be live. Claude Code will give you the Netlify URL.

---

## Phase 3: The Ongoing Workflow

Once the site is scaffolded and deployed, the day-to-day is simple.

### Adding new exercises

Open Claude Code in your project directory and describe what you want:

> Add a new exercise page for the couch stretch under lower-body/hips. It targets hip flexor lengthening, especially for people who sit all day. Hold for 2 minutes per side. Progression: elevate the back foot on a wall. Warning: skip if you have acute knee issues.

Claude Code creates the file with proper front matter, content structure matching your template, appropriate shortcodes, and correct weight values.

### Adding new sections

> Add a new subsection called "feet" under lower-body with exercises for toe spacer work, short foot drill, and plantar fascia release.

Claude Code creates the folder, the _index.md, and the stub pages.

### Deploying changes

```bash
git add . && git commit -m "Add couch stretch and feet section" && git push
```

Netlify rebuilds automatically on push. Or, if you want Claude Code to handle it:

> Commit all changes with the message "Add couch stretch and feet section", push to origin, and confirm the Netlify deploy started.

### Migrating content from Notion

Export your Notion pages as Markdown (Settings > Export in Notion). Then tell Claude Code:

> I've exported my Notion mobility content to ~/Downloads/notion-export/. Go through those files, clean up any Notion-specific formatting (toggle blocks, database references, callout syntax), convert Notion callouts to Relearn notice shortcodes, add proper front matter with title, weight, and tags, and place each file in the correct content/ subfolder based on its topic.

---

## Reference: Hugo + Relearn Concepts

This section is for your understanding of what Claude Code is building. You don't need to memorize any of it, but knowing the model helps when you want to ask for specific things.

### How the sidebar works

The Relearn theme generates the sidebar from your folder structure. Every folder with an `_index.md` becomes a collapsible section. Every standalone `.md` file becomes a leaf page. The `weight` front matter value controls ordering within a level (lower number = higher position).

```
content/
├── _index.md                    # Homepage
├── lower-body/
│   ├── _index.md                # "Lower Body" sidebar section
│   ├── hips/
│   │   ├── _index.md            # "Hips" nested section
│   │   ├── 90-90-stretch.md     # Exercise page (leaf)
│   │   └── pigeon-pose.md       # Exercise page (leaf)
```

### Front matter

Every Markdown file starts with metadata between `---` lines:

```yaml
---
title: "90/90 Hip Stretch"
weight: 10
tags: ["hips", "flexibility", "beginner"]
---
```

`weight` controls sidebar position. Using increments of 10 leaves room to insert new pages later without renumbering.

### Relearn shortcodes

These render as styled boxes in the content:

```markdown
{{% notice tip %}}
Keep your breathing steady. If you're holding your breath, you're pushing too hard.
{{% /notice %}}

{{% notice warning %}}
Skip this exercise if you have an acute knee injury.
{{% /notice %}}
```

Available types: tip, info, note, warning.

### Pagefind

Pagefind runs after Hugo builds the site. It crawls the HTML in `public/`, builds a compressed search index, and bundles a tiny JS/CSS search UI. When users search, it reads the pre-built index on their device. No server round-trip, so results feel instant.

The build sequence is always: Hugo first, Pagefind second.

```bash
hugo && npx -y pagefind --site public
```

Netlify runs this automatically on every deploy via the build command in `netlify.toml`.

### netlify.toml

This file lives in your project root and tells Netlify how to build:

```toml
[build]
  command = "hugo --environment production && npx -y pagefind --site public"
  publish = "public"

[build.environment]
  HUGO_VERSION = "0.146.0"
  NODE_VERSION = "22"
```

Adjust `HUGO_VERSION` to match your local install (`hugo version` to check).

### Custom styling

The Relearn theme uses CSS custom properties for theming. Your custom variant lives at `assets/css/theme-mobility.css`. The theme auto-discovers it when `themeVariant = ["mobility"]` is set in `hugo.toml`. You can override any of the theme's CSS variables there without touching theme files directly.

For layout tweaks beyond color, `layouts/partials/custom-header.html` is injected into every page's `<head>`. Put CSS overrides there.

### Theme updates

Tell Claude Code to update the Relearn theme submodule and push. Or manually:

```bash
cd themes/hugo-theme-relearn && git pull && cd ../..
git add themes/hugo-theme-relearn
git commit -m "Update Relearn theme" && git push
```

---

## What This Borrows from Johnny Decimal (and What It Doesn't)

The JD site uses folder names that are literally the decimal numbers (`10-19/11/11.01.md`), and the URL structure mirrors that numbering. Hugo's folder-to-sidebar behavior makes this work without much custom code.

For a mobility site, the numbering system isn't useful. Body region hierarchy (lower body > hips > specific exercise) is the natural taxonomy, and it's more intuitive for users than arbitrary decimals.

What you are borrowing from JD's approach:

- Folder-driven sidebar navigation with collapsible sections (Relearn does this natively)
- Clean, minimal design with fast load times (system fonts, no heavy JS frameworks)
- Static search that feels instant (Pagefind)
- Content-first philosophy (Markdown files, version controlled, no CMS lock-in)
- Lightweight and resilient: works without JavaScript, loads fast on any connection

---

## Troubleshooting

**Netlify MCP server won't authenticate:** Generate a Personal Access Token in the Netlify dashboard (User settings > OAuth > New access token) and add it to the MCP config temporarily. Remove it once CLI auth is working.

**Node version too low for Netlify MCP:** The server requires Node 22+. Check with `node --version` and upgrade via brew or nvm.

**Sidebar isn't showing pages:** Every folder needs an `_index.md`. Without it, Hugo doesn't register the folder as a section and its children won't appear in the sidebar.

**Pages in wrong order:** Check `weight` values in front matter. Lower weight = higher position. Missing weight falls back to alphabetical by title.

**Pagefind returns no results:** Pagefind indexes the built HTML in `public/`. If you're only running `hugo server` (which serves from memory, not disk), there's nothing for Pagefind to index. Run `hugo && npx -y pagefind --site public` first, then `hugo server`.

**Theme changes not showing:** Run `hugo server --disableFastRender` or clear your browser cache. Hugo's fast render mode can miss partial template changes.

**Netlify build fails:** The most common cause is a Hugo version mismatch. Make sure `HUGO_VERSION` in `netlify.toml` matches your local install. Check with `hugo version`.
