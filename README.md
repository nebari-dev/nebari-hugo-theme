<p align="center">
  <a href="https://nebari.dev">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/nebari-dev/nebari-design/main/logo-mark/horizontal/standard/Nebari-Logo-Horizontal-Lockup-White-text.png">
      <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/nebari-dev/nebari-design/main/logo-mark/horizontal/standard/Nebari-Logo-Horizontal-Lockup.png">
      <img alt="Nebari" src="https://raw.githubusercontent.com/nebari-dev/nebari-design/main/logo-mark/horizontal/standard/Nebari-Logo-Horizontal-Lockup.png" width="300">
    </picture>
  </a>
</p>

<h1 align="center">Nebari Hugo Theme</h1>

<p align="center">
  <strong>Minimal Hugo theme for Nebari software-pack documentation sites.</strong><br />
  Imports the OKLCH color tokens from <a href="https://github.com/nebari-dev/nebari-design">nebari-design</a>'s
  <code>@nebari/theme</code> so pack docs stay visually consistent with the rest of the Nebari ecosystem — header
  chrome, sidebar tree, multi-tab nav, client-side fuzzy search, dark mode, Catppuccin Mocha code blocks. Built
  around vanilla Hugo conventions so it stays small.
</p>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/screenshots/hero-dark.png">
    <source media="(prefers-color-scheme: light)" srcset="docs/screenshots/hero-light.png">
    <img src="docs/screenshots/hero-light.png" alt="nebari-hugo-theme home page — sidebar tree, Catppuccin Mocha code blocks, feature table" width="820">
  </picture>
</p>

<p align="center">
  <a href="https://github.com/nebari-dev/nebari-hugo-theme/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-BSD_3--Clause-blue.svg" alt="License"></a>
  <a href="https://gohugo.io"><img src="https://img.shields.io/badge/Hugo-0.116%2B-FF4088?logo=hugo&logoColor=white" alt="Hugo 0.116+"></a>
  <a href="https://www.typescriptlang.org"><img src="https://img.shields.io/badge/TypeScript-5.x-3178C6?logo=typescript&logoColor=white" alt="TypeScript"></a>
  <a href="https://github.com/nebari-dev/nebari-design"><img src="https://img.shields.io/badge/Tokens-%40nebari%2Ftheme-5809B3" alt="Powered by @nebari/theme"></a>
</p>

<p align="center">
  <a href="#what-is-nebari-hugo-theme">What is it?</a> &middot;
  <a href="#use-in-a-pack">Use in a pack</a> &middot;
  <a href="#local-preview">Local preview</a> &middot;
  <a href="#whats-shipped">What's shipped</a> &middot;
  <a href="#architecture">Architecture</a> &middot;
  <a href="#development">Development</a>
</p>

> **Status**: Early. Used by [`nebari-provenance-collector-pack`](https://github.com/nebari-dev/nebari-provenance-collector-pack)
> as the first consumer / shakedown site. Expect breaking changes until v0.1.

## What is Nebari Hugo Theme?

A small Hugo theme module that does **two things**:

1. **Imports the design tokens** from `@nebari/theme` so pack docs render with the same OKLCH palette, Inter +
   Fira Code typography, and primary purple as the rest of the Nebari ecosystem (the design library itself,
   `nebari-landing`, dashboards, future pack consumers).
2. **Owns the docs chrome** — header + sticky top nav with tabs + client-side search + sidebar tree with
   section grouping + dark-mode toggle + content / footer — so a consuming pack's repo only needs `content/*.md`
   and a 30-line `hugo.toml`.

Inspired by [`aktech/darby`](https://github.com/aktech/darby) — keeps the same fundamentals (multi-tab nav,
Fuse-backed search, dark code-on-light-page, sticky header) while trimming features less load-bearing for pack
docs (no in-browser LLM "Ask Assistant", no megamenu, no blog mode) and pulling visual identity from
`@nebari/theme` directly.

| | Light | Dark |
| :---: | :---: | :---: |
| Home  | ![Home — light](docs/screenshots/hero-light.png) | ![Home — dark](docs/screenshots/hero-dark.png) |
| Inner | ![Components page — light](docs/screenshots/components-light.png) | ![Components page — dark](docs/screenshots/components-dark.png) |

## Use in a pack

Add the theme as a Hugo Module in your pack's `hugo.toml`:

```toml
baseURL      = "https://nebari-dev.github.io/<your-pack>/"
languageCode = "en-US"
title        = "Your Pack Name"
theme        = ["github.com/nebari-dev/nebari-hugo-theme"]

[markup]
  [markup.highlight]
    noClasses   = false
    codeFences  = true
    guessSyntax = true
  [markup.goldmark.renderer]
    unsafe = true

# Enables client-side Fuse.js search — emits /index.json that search.ts fetches.
[outputs]
  home = ["HTML", "RSS", "JSON"]

[params]
  description = "One-line tagline shown under the title."
  repo        = "https://github.com/nebari-dev/<your-pack>"
  search      = true   # set to false to hide the search input

# Top-nav tabs. Active tab is determined by RelPermalink-prefix match.
[[params.tabs]]
  name = "Guides"
  url  = "/guides/"
[[params.tabs]]
  name = "Reference"
  url  = "/reference/"

# Sidebar tree.
[[params.sidebar]]
  heading = "Getting Started"
  [[params.sidebar.items]]
    label = "Overview"
    url   = "/"
  [[params.sidebar.items]]
    label = "Install"
    url   = "/install/"

[module]
  [[module.imports]]
    path = "github.com/nebari-dev/nebari-hugo-theme"
```

Initialize Hugo Modules in your pack repo:

```bash
hugo mod init github.com/nebari-dev/<your-pack>
hugo mod get -u
hugo server   # preview at http://localhost:1313
hugo          # build to public/
```

A consuming pack with this theme is shaped like:

```
docs/
  hugo.toml         # ~30 lines — title, sidebar tree, tabs
  go.mod            # generated by `hugo mod init`
  content/
    _index.md
    install.md
    …
  static/           # optional, pack-specific assets
```

That's the target footprint, matching Amit's
[`aktech/docs-site`](https://github.com/nebari-dev/nebari-data-science-pack/tree/aktech/docs-site) branch.

## Local preview

Clone, then use the bundled `Makefile`:

```bash
git clone git@github.com:nebari-dev/nebari-hugo-theme.git
cd nebari-hugo-theme
make dev          # http://localhost:1313, live-reload, edits in assets/ + layouts/ pick up immediately
```

The `exampleSite/` directory is a real Hugo site that imports the parent directory as a theme via a `replace`
directive in `exampleSite/go.mod`, so every theme change shows up without re-publishing. Other targets:

| Target | What it does |
| --- | --- |
| `make dev` | `hugo server` against `exampleSite/` with live reload |
| `make build` | Build the example site to `exampleSite/public/` (sanity check) |
| `make screenshots` | Boot Hugo headless, capture light + dark PNGs into `docs/screenshots/` |
| `make tidy` | Refresh Hugo Modules (run after editing imports) |
| `make clean` | Remove `public/`, `resources/`, and other Hugo build artifacts |

The screenshots embedded above are captured exactly this way — `make screenshots` is part of the contributor
loop, not an out-of-band script.

## What's shipped

| Feature | Status | Source |
| --- | --- | --- |
| Header chrome (logo + tabs + actions) | shipped | `layouts/partials/header.html` |
| Sticky multi-tab top nav (`[[params.tabs]]`) | shipped | `layouts/partials/header.html` |
| Left sidebar with section grouping (`[[params.sidebar]]`) | shipped | `layouts/partials/sidebar.html` |
| Dark-mode toggle with FOUC prevention | shipped | `layouts/partials/head.html` + `assets/js/theme-toggle.ts` |
| Client-side fuzzy search (Fuse.js 7.1) | shipped | `assets/js/search.ts` + `layouts/_default/index.json` |
| Catppuccin Mocha code highlighting (Chroma) | shipped | `assets/css/main.css` |
| Fira Code in code blocks, Inter in body | shipped | `assets/css/main.css` |
| `@nebari/theme` OKLCH token import | shipped | `assets/css/main.css` |
| Edit-on-GitHub link | not yet | — |
| Table of contents widget | not yet | — |
| `prefers-reduced-motion` audit | not yet | — |

## Architecture

```
nebari-hugo-theme/
  assets/
    css/main.css                 OKLCH tokens + chrome + Chroma palette
    js/theme-toggle.ts           Dark-mode toggle (esbuild-compiled by js.Build)
    js/search.ts                 Fuse.js search wiring
    vendor/fuse.basic.min.mjs    Vendored Fuse 7.1 (~13 KB)
  layouts/
    _default/
      baseof.html                Page shell; bundles + SRI-hashes the TS modules
      home.html / single.html / list.html
      index.json                 Search-index template (one record per RegularPage)
    partials/
      head.html                  Meta + FOUC-prevention script + CSS link
      header.html                Logo + tabs + search + theme toggle + GitHub
      sidebar.html               Sidebar tree from [[params.sidebar]]
      footer.html
  exampleSite/                   Consumer-shape demo for local preview
  docs/screenshots/              README hero images, regenerated by `make screenshots`
  Makefile
  theme.toml                     Theme metadata for Hugo's theme catalog
  go.mod                         Hugo Module init
```

The two TS modules are compiled through Hugo's built-in `js.Build` (esbuild) in `baseof.html` and shipped as ES
modules with SRI integrity hashes. `tsconfig.json` is present for editor support — Hugo handles the actual build.

## Development

Requirements:

- **Hugo extended ≥ 0.116** — needs the `js.Build` (esbuild) pipeline
- **Go ≥ 1.20** — for Hugo Modules
- **Node** — not required; TS goes through Hugo, not npm

Quick loop:

```bash
make dev                       # live preview
# … edit assets/, layouts/, content in exampleSite/content/ …
make screenshots               # regenerate README images when chrome changes
git commit -am "feat: …"
```

Contributions welcome — open a PR. The theme follows
[Hugo's theme conventions](https://gohugo.io/hugo-modules/theme-components/) and tries to keep its scope narrow:
if a feature is more pack-specific than docs-theme-specific, it probably belongs in the consuming pack instead.

## Acknowledgements

[`aktech/darby`](https://github.com/aktech/darby) by Amit Kumar — Amit's Hugo theme used on
`nebari-data-science-pack`'s docs spike. This theme keeps darby's general shape and trims out features pack docs
don't need (browser-LLM assistant, blog mode, megamenu) in favor of being thin and importing the Nebari design
tokens directly.

[`@nebari/theme`](https://github.com/nebari-dev/nebari-design) — the OKLCH token source-of-truth. Refresh the
copied tokens in `assets/css/main.css` when upstream changes.

## License

[BSD-3-Clause](LICENSE) — same as the rest of the Nebari Infrastructure Core stack.
