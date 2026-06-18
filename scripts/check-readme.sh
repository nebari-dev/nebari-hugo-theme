#!/usr/bin/env bash
# check-readme.sh - Catch drift between README.md and the repo it documents.
#
# The README hand-maintains three things that duplicate source of truth and
# silently rot when files move or Makefile targets are renamed:
#
#   1. Makefile targets   - every `make <target>` mentioned in README.md must
#                           exist as a real rule in the Makefile.
#   2. Feature table      - every backticked path in the "Source" column of the
#                           "What's shipped" table must exist on disk.
#   3. Architecture tree  - every file/dir drawn in the "## Architecture" tree
#                           must exist on disk.
#
# This validates existence only - it does not regenerate prose. Editorial
# columns (feature names, status) stay hand-written.
#
# Usage: scripts/check-readme.sh
# Exit 0 + prints README_OK on success; non-zero + a per-failure report otherwise.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
README="${ROOT}/README.md"
MAKEFILE="${ROOT}/Makefile"

cd "${ROOT}"

fail=0
report() { printf '  FAIL: %s\n' "$1" >&2; fail=1; }

# Expand a single {a,b,...} brace group (bash brace expansion does not fire on
# variable contents). Only the one-group case the README uses is handled.
expand_braces() {
  local token="$1"
  if [[ "${token}" == *"{"*","*"}"* ]]; then
    local pre="${token%%\{*}" body="${token#*\{}" post
    post="${body#*\}}"
    body="${body%%\}*}"
    local part
    IFS=',' read -ra parts <<<"${body}"
    for part in "${parts[@]}"; do
      printf '%s\n' "${pre}${part}${post}"
    done
  else
    printf '%s\n' "${token}"
  fi
}

# Check that a path token exists (trailing slash = directory).
check_path() {
  local p
  while IFS= read -r p; do
    [[ -z "${p}" ]] && continue
    if [[ "${p}" == */ ]]; then
      [[ -d "${p%/}" ]] || report "$1: directory not found: ${p}"
    else
      [[ -e "${p}" ]] || report "$1: file not found: ${p}"
    fi
  done < <(expand_braces "$1")
}

echo "==> 1. Makefile targets referenced in README"
mapfile -t make_targets < <(grep -oE '^[a-zA-Z_-]+:' "${MAKEFILE}" | sed 's/://')
is_target() {
  local t
  for t in "${make_targets[@]}"; do [[ "${t}" == "$1" ]] && return 0; done
  return 1
}
mapfile -t referenced < <(grep -oE 'make [a-z][a-z-]+' "${README}" | awk '{print $2}' | sort -u)
for t in "${referenced[@]}"; do
  is_target "${t}" || report "README references \`make ${t}\` but Makefile has no such target"
done

echo "==> 2. Source-column paths in the 'What's shipped' table"
# Rows live between "## What's shipped" and the next "## " heading. For each
# table row, take the 3rd pipe-delimited cell and check its backticked paths.
# Process substitution keeps the loop in the main shell so report() sticks.
while IFS= read -r token; do
  [[ -z "${token}" ]] && continue
  check_path "${token}"
done < <(
  awk '/^## What.s shipped/{f=1;next} /^## /{f=0} f && /^\|/{print}' "${README}" \
    | awk -F'|' 'NF>=4{print $4}' \
    | grep -oE '`[^`]+`' | tr -d '`' | sed 's/^ *//;s/ *$//' \
    | grep -vE '^[—-]$' | sort -u
)

echo "==> 3. Architecture directory tree"
# Walk the fenced tree, reconstructing full paths from 2-space indentation.
# A token ending in "/" is a directory level; otherwise it's a leaf file
# (possibly several separated by " / ").
declare -a stack
first=1
while IFS= read -r line; do
  [[ -z "${line}" ]] && continue
  # leading spaces -> depth
  stripped="${line#"${line%%[![:space:]]*}"}"
  indent=$(( ${#line} - ${#stripped} ))
  depth=$(( indent / 2 ))
  # token = text up to first run of 2+ spaces
  token="${stripped%%"  "*}"
  token="${token%"${token##*[![:space:]]}"}"
  if [[ ${first} -eq 1 ]]; then first=0; continue; fi  # skip root line
  # build parent prefix from stack[1..depth-1]
  prefix=""
  for ((i=1; i<depth; i++)); do prefix+="${stack[i]}/"; done
  if [[ "${token}" == */ ]]; then
    stack[depth]="${token%/}"
    check_path "${prefix}${token}"
  else
    # may be several files separated by " / ": "a.html / b.html / c.html".
    # Split on the literal " / " string (not the / char, which is path syntax).
    while IFS= read -r leaf; do
      [[ -z "${leaf}" ]] && continue
      check_path "${prefix}${leaf}"
    done <<<"${token// \/ /$'\n'}"
  fi
done < <(
  awk '/^## Architecture/{a=1} a&&/^```/{c++; next} a&&c==1{print} c>=2{exit}' "${README}"
)

if [[ "${fail}" -ne 0 ]]; then
  echo "" >&2
  echo "README drift detected. Update README.md (or the moved files) and re-run." >&2
  exit 1
fi

echo "README_OK"
