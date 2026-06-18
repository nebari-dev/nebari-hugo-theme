+++
title = 'CI/CD and Releasing'
description = "Automated testing, versioning, and release process for Nebari software packs."
+++

This page explains the CI/CD pipeline and the release workflow used by the `llm-serving` pack.

## CI pipeline overview

The repository uses GitHub Actions. Every pull request runs the following jobs in parallel:

| Job | What it does |
| --- | --- |
| `lint` | `helm lint` + `ct lint` against all chart directories |
| `unit-test` | `helm unittest` for template rendering tests |
| `integration` | Deploys to a `kind` cluster and runs `helm test` |
| `docs` | Builds the Hugo docs site; fails on broken links |

## Release workflow

Releases are cut by pushing a semver tag. The `release` workflow:

1. Runs the full CI suite on the tagged commit.
2. Packages the chart with `helm package`.
3. Pushes the chart to the GitHub Pages OCI registry.
4. Creates a GitHub Release with the changelog.

```bash
# Cut a release
git tag v0.2.0
git push origin v0.2.0
```

## Versioning

The pack follows [Semantic Versioning](https://semver.org/):

- **Patch** (`0.1.x`): bug fixes, doc updates, dependency bumps with no values changes.
- **Minor** (`0.x.0`): new optional values keys, backwards-compatible behaviour changes.
- **Major** (`x.0.0`): breaking changes to values schema or required cluster prerequisites.

The `Chart.yaml` `version` field tracks the chart version; `appVersion` tracks the upstream inference server version.

## Dependency updates

Dependabot monitors Helm chart dependencies and container image digests. PRs are opened automatically; the maintainer merges after CI passes.

> Always check the upstream changelog before merging a major dependency bump - breaking API changes in the inference server may require values schema updates.
