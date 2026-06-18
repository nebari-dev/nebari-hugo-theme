# nebari-hugo-theme

Minimal Hugo theme for [Nebari](https://www.nebari.dev/) software-pack documentation sites.

Imports the OKLCH color tokens from [`nebari-design`](https://github.com/nebari-dev/nebari-design)'s `@nebari/theme` so pack docs stay visually consistent with the rest of the Nebari ecosystem (apps, dashboards, the design system itself). Layout is intentionally small: header + left sidebar + content + footer, dark-mode toggle, Catppuccin Mocha syntax highlighting via class-emitted Chroma, Fira Code in code blocks.

Compared with general-purpose Hugo doc themes (Doks, Hextra, Geekdocs), this theme:

- ships fewer features so pack maintainers configure less,
- pulls its primary palette from `nebari-design`'s `globals.css` so design changes there propagate here on update,
- expects content to live under `content/` directly (no special section conventions beyond Hugo's defaults).

## Use

Add the theme as a Hugo Module in your site's `hugo.toml`:

```toml
baseURL = "https://nebari-dev.github.io/<your-pack>/"
title  = "Your pack name"
theme  = "nebari-hugo-theme"

[module]
  [[module.imports]]
    path = "github.com/nebari-dev/nebari-hugo-theme"

# Hugo doesn't merge a theme's [markup] block into a consuming site, so this
# must live in the consuming site:
[markup]
  [markup.highlight]
    noClasses    = false
    codeFences   = true
    guessSyntax  = true
  [markup.goldmark.renderer]
    unsafe = true

[params]
  # Optional. Defaults shown.
  logo        = "https://raw.githubusercontent.com/nebari-dev/nebari-design/main/logo-mark/horizontal/standard/Nebari-Logo-Horizontal-Lockup.png"
  repo        = "https://github.com/nebari-dev/<your-pack>"
  description = "One-line tagline shown under the title."

[[params.sidebar]]
  heading = "Getting Started"
  [[params.sidebar.items]]
    label = "Overview"
    url   = "/"
  [[params.sidebar.items]]
    label = "Install"
    url   = "/install/"
```

Initialize Hugo Modules in your repo:

```bash
hugo mod init github.com/nebari-dev/<your-pack>
hugo mod get -u
```

Then `hugo server` to preview, `hugo` to build to `public/`.

## Status

Early. Used by [`nebari-provenance-collector-pack`](https://github.com/nebari-dev/nebari-provenance-collector-pack) as the first consumer / shakedown site. Expect breaking changes until v0.1.

## Why a separate repo

So each pack's docs site is the *smallest possible diff* — `content/*.md` + a 30-line `hugo.toml` + (optionally) `static/`. The theme owns layout, typography, code highlighting, dark-mode, and the design-system token import. Update the theme once and every pack picks it up on `hugo mod get -u`.

## Acknowledgements

Inspired by [`aktech/darby`](https://github.com/aktech/darby), Amit Kumar's Hugo theme used on `nebari-data-science-pack`'s docs spike. This theme keeps darby's general shape (sidebar tree, dark code-on-light-page, sticky header) but trims out features pack docs don't need (multi-tab top nav, fuse search, browser-LLM assistant) in favor of being thin and importing the Nebari design tokens directly.
