# Design Token Source

The CSS custom-property color tokens in `assets/css/main.css` are lifted verbatim from
[nebari-design](https://github.com/nebari-dev/nebari-design) `globals.css`.

## Source

- Repository: https://github.com/nebari-dev/nebari-design
- File: `globals.css` (shadcn-style design tokens)
- Pinned at commit: `6e544711254ba7566fcc43e30f67757431684759` (refs/heads/main as of 2026-06-18)

## Verbatim-copy rule

The tokens in `main.css` are a verbatim copy of the upstream `globals.css` `:root` and `.dark`
blocks. Do **not** modify them locally. To refresh tokens, re-copy from the upstream file at the
desired commit and update the SHA recorded above.

## Self-hosted fonts

Fonts are downloaded from the [Fontsource](https://fontsource.org/) jsDelivr CDN and committed to
`static/fonts/`. The following woff2 files are included:

| File | Family | Weight | Role |
|------|--------|--------|------|
| `poppins-latin-600-normal.woff2` | Poppins | 600 | Headings (semibold) |
| `poppins-latin-700-normal.woff2` | Poppins | 700 | Headings (bold) |
| `atkinson-hyperlegible-latin-400-normal.woff2` | Atkinson Hyperlegible | 400 | Body (regular) |
| `atkinson-hyperlegible-latin-700-normal.woff2` | Atkinson Hyperlegible | 700 | Body (bold) |
| `fira-code-latin-400-normal.woff2` | Fira Code | 400 | Monospace / code |
| `fira-code-latin-500-normal.woff2` | Fira Code | 500 | Monospace / code |
| `fira-code-latin-600-normal.woff2` | Fira Code | 600 | Monospace / code |

Source CDN path pattern: `https://cdn.jsdelivr.net/npm/@fontsource/<family>/files/<filename>.woff2`
