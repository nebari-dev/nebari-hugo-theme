+++
title = 'nebari-hugo-theme'
description = "Run `hugo server` in this repo to preview the theme. Edit content/_index.md to play with prose, code blocks, and tables."
+++

{{< callout type="warning" title="Archived version (v0.1)" >}}
You're viewing the **v0.1** snapshot, rebuilt from the `demo/v0.1` git tag.
The latest docs are at **[v0.2](https://nebari-dev.github.io/nebari-hugo-theme/)**.
{{< /callout >}}

This is the demo content shipped with the theme so contributors can run
`hugo server` from this repo and see what the theme looks like without
having to set up a consuming site.

## Code block

```python
def greet(name: str) -> str:
    """Catppuccin Mocha via class-emitted Chroma."""
    return f"Hello, {name}!"
```

## Table

| Feature | Status |
| --- | --- |
| Sidebar | shipped |
| Dark mode | shipped |
| Code highlighting | shipped |
| Multi-tab nav | shipped |
| Client-side search (Fuse.js, `/` shortcut) | shipped |
| Copy buttons on code blocks | shipped |
| Mermaid diagrams | shipped |
| Heading anchor permalinks | shipped |
| Breadcrumbs | shipped |
| Last-updated stamp (`enableGitInfo`) | shipped |
| i18n (`i18n/<code>.toml` + `[languages.*]`) | shipped |
| Versioning (`[[params.versions]]` dropdown) | shipped |
| 404 page | shipped |
| Edit-on-GitHub link | not yet |
| Table of contents widget | not yet |

## Inline `code` and a [link](https://www.nebari.dev/).

> A blockquote, themed with the primary OKLCH purple.
