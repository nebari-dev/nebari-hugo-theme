#!/usr/bin/env bash
# verify-module.sh - Prove the theme is consumable as a Hugo Module (journey 7).
#
# Creates a throwaway consumer site that imports
# github.com/nebari-dev/nebari-hugo-theme via Hugo Modules with a local
# `replace` pointing at the working tree, builds it with `hugo`, and
# asserts a themed marker appears in the output HTML.
#
# Usage: scripts/verify-module.sh
# Exit 0 + prints MODULE_CONSUMPTION_OK on success; non-zero + message on failure.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

WORK_DIR=""
cleanup() {
  if [[ -n "${WORK_DIR}" && -d "${WORK_DIR}" ]]; then
    rm -rf "${WORK_DIR}"
  fi
}
trap cleanup EXIT

echo "==> Theme dir: ${THEME_DIR}"
echo "==> Creating temp consumer site..."

WORK_DIR="$(mktemp -d)"
SITE_DIR="${WORK_DIR}/consumer-site"
mkdir -p "${SITE_DIR}/content"

# ---- hugo.toml ----
# Mirrors the module import + replace pattern from exampleSite/hugo.toml.
# module.replacements uses a comma-separated string of "import => local" pairs.
cat > "${SITE_DIR}/hugo.toml" <<'TOML'
baseURL      = "https://example.com/"
languageCode = "en-US"
title        = "Module consumption test"
theme        = ["github.com/nebari-dev/nebari-hugo-theme"]

[outputs]
  home = ["HTML", "RSS", "JSON"]

[params]
  description = "Verify module consumption."

  [[params.sidebar]]
    heading = "Test"
    [[params.sidebar.items]]
      label = "Home"
      url   = "/"
    [[params.sidebar.items]]
      label = "About"
      url   = "/about/"

[module]
  [module.hugoVersion]
    extended = true
    min      = "0.116.0"
  [[module.imports]]
    path = "github.com/nebari-dev/nebari-hugo-theme"
TOML

# ---- go.mod ----
# Mirrors exampleSite/go.mod: module path + replace pointing at THEME_DIR.
cat > "${SITE_DIR}/go.mod" <<GOMOD
module github.com/nebari-dev/nebari-hugo-theme/consumer-test

go 1.21

replace github.com/nebari-dev/nebari-hugo-theme => ${THEME_DIR}

require github.com/nebari-dev/nebari-hugo-theme v0.0.0-20260618030810-22e38f6e7abb // indirect
GOMOD

# ---- Minimal content ----
cat > "${SITE_DIR}/content/_index.md" <<'MD'
+++
title = "Module test home"
+++

Verifying that the nebari-hugo-theme is consumable as a Hugo Module.
MD

mkdir -p "${SITE_DIR}/content/about"
cat > "${SITE_DIR}/content/about/_index.md" <<'MD'
+++
title = "About"
+++

About page for module consumption test.
MD

# ---- Build ----
echo "==> Running hugo build..."
BUILD_OUTPUT="$(hugo --source "${SITE_DIR}" --destination "${WORK_DIR}/public" --quiet 2>&1)" || {
  echo "ERROR: hugo build failed:"
  echo "${BUILD_OUTPUT}"
  exit 1
}

# ---- Assert themed marker in output HTML ----
MARKER="site-header__"
HTML_FILES=("${WORK_DIR}/public/index.html")

FOUND=0
for f in "${HTML_FILES[@]}"; do
  if [[ -f "${f}" ]] && grep -q "${MARKER}" "${f}"; then
    FOUND=1
    break
  fi
done

# Also search all generated HTML if index.html didn't match
if [[ "${FOUND}" -eq 0 ]]; then
  if grep -r -l "${MARKER}" "${WORK_DIR}/public/" 2>/dev/null | grep -q .; then
    FOUND=1
  fi
fi

if [[ "${FOUND}" -eq 0 ]]; then
  echo "ERROR: themed marker '${MARKER}' not found in generated HTML."
  echo "       Build output: ${WORK_DIR}/public/"
  echo "       (cleanup suppressed for inspection - remove manually)"
  # Cancel trap so the dir survives for debugging
  trap - EXIT
  exit 1
fi

echo "MODULE_CONSUMPTION_OK"
