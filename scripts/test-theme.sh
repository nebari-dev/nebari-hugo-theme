#!/usr/bin/env bash
# test-theme.sh - Behavioral tests for the theme's rendered output.
#
# Builds exampleSite/ once (under a subpath baseURL, to exercise URL
# prefixing) and asserts the contracts that are easy to regress:
#
#   - Responsive nav: tabs + version + language are re-surfaced inside the
#     off-canvas drawer (they're display:none in the header on mobile).
#   - Tables: every Markdown table is wrapped in a horizontal-scroll
#     container, with its head/body structure preserved.
#   - The CSS/JS contracts those depend on are present.
#
# These run without a browser, so they live in CI. Rendering-level checks
# (actual media-query behaviour) are covered by `make screenshots` locally.
#
# Usage: scripts/test-theme.sh        (HUGO=/path/to/hugo to override)
# Exit 0 + prints THEME_TESTS_OK on success; non-zero + a report otherwise.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
HUGO="${HUGO:-hugo}"
CSS="${ROOT}/assets/css/main.css"
NAVJS="${ROOT}/assets/js/nav-toggle.ts"

cd "${ROOT}"

OUT="$(mktemp -d)"
cleanup() { rm -rf "${OUT}"; }
trap cleanup EXIT

pass=0 fail=0
ok()   { printf '  ok   %s\n' "$1"; pass=$((pass + 1)); }
bad()  { printf '  FAIL %s\n' "$1" >&2; fail=$((fail + 1)); }

# assert that a file contains a pattern (grep -E, single line); report by message
has() { # <file> <pattern> <message>
  if grep -Eq "$2" "$1"; then ok "$3"; else bad "$3"; fi
}
# multiline-aware match (Python regex, DOTALL) — needed for CSS rule blocks
# that span braces across lines, which line-based grep can't see.
pyhas() { # <file> <python-regex> <message>
  if python3 -c "import re,sys; sys.exit(0 if re.search(sys.argv[2], open(sys.argv[1]).read(), re.S) else 1)" "$1" "$2"; then
    ok "$3"; else bad "$3"; fi
}
pylacks() { # <file> <python-regex> <message>
  if python3 -c "import re,sys; sys.exit(0 if re.search(sys.argv[2], open(sys.argv[1]).read(), re.S) else 1)" "$1" "$2"; then
    bad "$3"; else ok "$3"; fi
}

echo "==> Building exampleSite (subpath baseURL)"
# --minify so the output matches what we deploy (unquoted attrs, no
# inter-tag whitespace) — the assertions below target that exact form.
"${HUGO}" -s exampleSite --quiet --minify --baseURL "https://example.test/sub/" --destination "${OUT}" 2>&1 \
  || { echo "ERROR: hugo build failed" >&2; exit 1; }

HOME_HTML="${OUT}/index.html"
CFG_HTML="${OUT}/configuration/index.html"
for f in "${HOME_HTML}" "${CFG_HTML}"; do
  [[ -f "$f" ]] || { echo "ERROR: expected built page missing: $f" >&2; exit 1; }
done

echo "==> Tables"
# Every <table> in the build is wrapped in .table-wrap (count parity per page).
unwrapped=0
while IFS= read -r f; do
  t=$(grep -oc '<table>' "$f" || true)
  w=$(grep -oc 'table-wrap' "$f" || true)
  if [[ "$t" != "0" && "$t" != "$w" ]]; then
    bad "unwrapped table(s) in ${f#${OUT}/} (tables=$t wraps=$w)"; unwrapped=1
  fi
done < <(find "${OUT}" -name '*.html')
[[ "$unwrapped" == "0" ]] && ok "every table is wrapped in .table-wrap"
# Wrapper actually wraps the table, and structure is preserved.
has "${HOME_HTML}" '<div class=table-wrap><table>' "table-wrap wraps the <table> element"
has "${HOME_HTML}" '<table><thead><tr><th>' "table head/body structure preserved by render hook"

echo "==> Mobile nav re-surfaces header chrome"
# Extract just the .sidebar__mobile-nav block from the home page.
BLOCK="$(python3 - "$HOME_HTML" <<'PY'
import re, sys
s = open(sys.argv[1]).read()
i = s.find('sidebar__mobile-nav')
# grab a generous slice; the block precedes the first docs-tree <details>
seg = s[i:i + 1600]
cut = seg.find('<details')
print(seg if cut == -1 else seg[:cut])
PY
)"
echo "${BLOCK}" > "${OUT}/_mobile_block.txt"
has "${OUT}/_mobile_block.txt" 'Sections'                                   "drawer has a Sections group"
has "${OUT}/_mobile_block.txt" 'href=/sub/components/'                      "drawer surfaces the section tabs"
has "${OUT}/_mobile_block.txt" 'Version'                                    "drawer has a Version group"
has "${OUT}/_mobile_block.txt" 'href=https://nebari-dev.github.io/nebari-hugo-theme/v0.1/' "drawer surfaces version links"
has "${OUT}/_mobile_block.txt" 'Language'                                   "drawer has a Language group"
has "${OUT}/_mobile_block.txt" 'href=/sub/es/'                              "drawer surfaces language links"

echo "==> CSS contracts"
pyhas "${CSS}" '\.sidebar__mobile-nav \{ display: none; \}'   "mobile nav hidden on desktop"
pyhas "${CSS}" '\.sidebar__mobile-nav \{[^}]*display: block'  "mobile nav shown in the <=768px query"
pyhas "${CSS}" '\.main \.table-wrap \{[^}]*overflow-x: auto'  ".table-wrap scrolls horizontally"
pyhas "${CSS}" '\.main \{[^}]*overflow-wrap: break-word'      "long tokens wrap instead of overflowing"
# Backdrop must sit below the header (z-index 20) so the toggle stays clickable.
pyhas   "${CSS}" '\.nav-backdrop \{[^}]*z-index: 15'          "backdrop z-index below the header"
pylacks "${CSS}" '\.nav-backdrop \{[^}]*z-index: 29'          "backdrop no longer occludes the header"

echo "==> JS contracts (nav-toggle)"
has "${NAVJS}" "nav-open"      "drawer locks background scroll (body.nav-open)"
has "${NAVJS}" "'Tab'"         "drawer traps Tab focus"
has "${NAVJS}" "closeSidebar"  "drawer closes on link / backdrop / escape"

echo ""
echo "passed: ${pass}, failed: ${fail}"
if [[ "${fail}" -ne 0 ]]; then
  echo "THEME_TESTS_FAILED" >&2
  exit 1
fi
echo "THEME_TESTS_OK"
