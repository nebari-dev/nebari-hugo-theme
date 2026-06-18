+++
title = 'Components'
description = "What the theme renders by default. Add markdown to content/, the theme handles the chrome."
+++

This page exists so the demo site has more than one document to index — try the search box in the header.

## Headings

Hugo renders standard markdown. The theme styles `h1` through `h3` with the
@nebari/theme primary color and Inter font.

## Lists

- Bulleted items
- Get a little indentation
- And `inline code` styling
- Plus links to [external resources](https://www.nebari.dev/)

## Pre-formatted blocks

```toml
[markup.highlight]
  noClasses = false
  codeFences = true
  guessSyntax = true
```

```yaml
nebariapp:
  enabled: true
  hostname: provenance.example.com
```

## Tables

| Token | Light | Dark |
| --- | --- | --- |
| `--primary` | `oklch(0.5809 0.2683 319.62)` | `oklch(0.6809 0.2483 319.62)` |
| `--background` | `oklch(1 0 0)` | `oklch(0.1743 0.0105 276.35)` |
| `--foreground` | `oklch(0.1743 0.0105 276.35)` | `oklch(0.985 0 0)` |

## Mermaid diagrams

Fenced ` ```mermaid ` blocks are lazy-rendered by `assets/js/mermaid-init.ts`.

```mermaid
flowchart LR
    A[Markdown] -->|hugo build| B[HTML]
    B --> C{theme}
    C -->|@nebari/theme tokens| D[styled output]
    C -->|class-emitted Chroma| E[code blocks]
```

## Blockquotes

> Quoted text picks up the primary purple bar on the left and a muted
> background tint — useful for callouts in install runbooks.

## Callouts

{{< callout type="note" >}}
Default note callout. Inline `code` and **bold** work inside.
{{< /callout >}}

{{< callout type="tip" title="Heads up" >}}
This is a tip callout.
{{< /callout >}}

{{< callout type="warning" >}}
Something might go wrong here. Check your configuration before proceeding.
{{< /callout >}}

{{< callout type="caution" >}}
Irreversible action ahead. Make sure you have a backup.
{{< /callout >}}
