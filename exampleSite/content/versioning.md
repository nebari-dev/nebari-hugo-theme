+++
title = 'Versioning'
description = "Ship versioned docs without keeping a copy of every version in your repo — rebuild each one from its git tag at deploy time."
+++

This theme ships a **version picker** (the dropdown next to the search box). It
lets readers jump between `v0.2`, `v0.1`, and so on. The picker itself is just a
list of links — the interesting part is *how you publish those versions without
duplicating your docs*.

{{< callout type="tip" title="The one idea" >}}
You only ever keep **one** copy of the docs in your repo — the current ones, on
`main`. Every past version already exists in git history as the **tag** you cut
when you released it. At deploy time, CI rebuilds each tag into its own `/vX.Y/`
subpath. No `v0.1/` folder lives in your working tree.
{{< /callout >}}

## How the picker works

Each version is an **independently-deployed site** at its own URL. The current
docs sit at the site root; each older version lives under a `/vX.Y/` subpath.
You list them in `hugo.toml`:

```toml
[[params.versions]]
  label   = "v0.2 (latest)"
  url     = "https://nebari-dev.github.io/<pack>/"
  current = true
[[params.versions]]
  label = "v0.1"
  url   = "https://nebari-dev.github.io/<pack>/v0.1/"
```

{{< callout type="warning" title="Use cross-deploy URLs" >}}
Version `url`s must be **absolute** (or site-root-relative like `/<pack>/v0.1/`).
They are emitted verbatim — *not* resolved against the page's `baseURL`. A page
served under `/<pack>/v0.1/` has to link up-and-over to `/<pack>/v0.2/`, and a
`baseURL`-relative link can't express that. A bare `/` or `quickstart/` will
break once the page is itself served from a `/vX.Y/` subpath.
{{< /callout >}}

## The deploy recipe (no copies)

The pattern: build the **current** docs at the root, then for each released tag,
check it out and build it into a `/vX.Y/` subdirectory of the *same* output. The
whole thing is uploaded as a single GitHub Pages artifact.

```yaml
# In your Pages deploy workflow, after setup-go + hugo install:

- name: Build current docs (root)
  run: hugo --gc --minify --baseURL "https://nebari-dev.github.io/<pack>/"

# For each version you want to keep online, check out its tag and build
# it into public/<version>/. Loop over as many as you like.
- name: Check out v0.1
  uses: actions/checkout@v7
  with:
    ref: v0.1.0          # the git tag for that release
    path: _v0.1

- name: Build v0.1 into /v0.1/
  run: |
    cd _v0.1 && hugo --gc --minify \
      --baseURL "https://nebari-dev.github.io/<pack>/v0.1/" \
      --destination "$GITHUB_WORKSPACE/public/v0.1"

# public/ now holds: current docs at the root + a frozen v0.1/ subtree.
# Upload it as one artifact and deploy.
```

Because each version is rebuilt from its tag, the only docs in your working tree
are the current ones. To retire a version, drop its build step and its
`[[params.versions]]` entry — the old subpath simply stops being published.

{{< callout type="note" title="Tip: build versions in a loop" >}}
For more than one or two versions, replace the per-tag steps with a matrix or a
shell loop over a list of tags (`for v in v0.1.0 v0.2.0; do …; done`), building
each into `public/${v%.*}/`. The principle is unchanged.
{{< /callout >}}

## Keeping the picker consistent

Each deployed version carries its **own** `hugo.toml`, so its picker lists only
the versions that existed when that tag was cut — an old `v0.1` site won't know
about a later `v0.2`. Two ways to handle it:

- **Good enough:** accept that older sites point "forward" only to whatever they
  knew about, and always link **latest** prominently. Readers landing on an old
  page can still click up to the current docs.
- **Fully consistent:** when you release a new version, also update the
  `[[params.versions]]` list on the tags you still publish (re-tag, or build old
  refs with the *current* `hugo.toml` overlaid). This keeps every deploy's
  dropdown in sync at the cost of a little more deploy plumbing.

This theme keeps versioning intentionally simple — static per-build config rather
than a shared runtime manifest — so the first option is the default. Reach for
the second only when you maintain many long-lived versions.
