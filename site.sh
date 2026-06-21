#!/usr/bin/env bash
# site.sh — convenience wrapper for the Dunn With Love Quilting site.
#
# Usage:  ./site.sh <command>
#
# Run from the repo root.

set -euo pipefail

cd "$(dirname "$0")"

# ---- pretty output helpers ----
c_reset=$'\033[0m'
c_dim=$'\033[2m'
c_blue=$'\033[34m'
c_green=$'\033[32m'
c_red=$'\033[31m'
say()    { printf '%s→%s %s\n' "$c_blue" "$c_reset" "$*"; }
ok()     { printf '%s✓%s %s\n' "$c_green" "$c_reset" "$*"; }
die()    { printf '%s✗%s %s\n' "$c_red" "$c_reset" "$*" >&2; exit 1; }

# ---- checks ----
require_hugo() {
  command -v hugo >/dev/null 2>&1 || die "hugo not found. Install with: brew install hugo"
  if ! hugo version | grep -q extended; then
    die "Hugo extended is required (you have non-extended). Reinstall: brew uninstall hugo && brew install hugo"
  fi
}

cmd_help() {
  cat <<'EOF'
Dunn With Love Quilting — site.sh

USAGE
  ./site.sh <command>

COMMANDS
  dev          Start the local dev server with live reload at http://localhost:1313
  build        Production build to ./public (minified, GC, dropped drafts)
  preview      Production build, then serve ./public for a final look
  clean        Remove build artifacts (./public, ./resources, .hugo_build.lock)
  check        Clean build with broken-link warnings printed
  invoice      Open the printable invoice template in your default browser
  install      One-time setup notes (Hugo install command + reminders)
  help         Show this message

EXAMPLES
  ./site.sh dev          # while editing content/templates
  ./site.sh build        # one-shot production build
  ./site.sh check        # before pushing — fails on template errors
EOF
}

cmd_install() {
  cat <<'EOF'
One-time setup
==============
  brew install hugo            # Hugo extended (required)
  brew install imagemagick     # only needed if you regenerate the favicon

Then:
  ./site.sh dev                # start the dev server
EOF
}

cmd_dev() {
  require_hugo
  say "Starting Hugo dev server at http://localhost:1313"
  say "Edit anything under content/, layouts/, assets/, or hugo.toml — it'll live-reload."
  exec hugo server \
    --port 1313 \
    --bind 127.0.0.1 \
    --disableFastRender \
    --navigateToChanged \
    --buildDrafts
}

cmd_build() {
  require_hugo
  say "Production build → ./public"
  hugo --minify --gc --cleanDestinationDir
  ok "Built. Files in ./public ($(find public -type f | wc -l | tr -d ' ') files)."
}

cmd_preview() {
  cmd_build
  say "Serving ./public at http://localhost:1314"
  cd public && exec python3 -m http.server 1314 --bind 127.0.0.1
}

cmd_clean() {
  say "Removing build artifacts"
  rm -rf public resources .hugo_build.lock
  ok "Clean."
}

cmd_check() {
  require_hugo
  say "Clean production build with warnings"
  rm -rf public resources
  hugo --minify --gc --printPathWarnings --printUnusedTemplates 2>&1 | tee /tmp/hugo-build.log
  if grep -qi "error\|WARN.*broken" /tmp/hugo-build.log; then
    die "Build emitted warnings or errors — see above."
  fi
  ok "Build clean. ./public is ready to deploy."
}

cmd_invoice() {
  local f="$PWD/tools/invoice-template.html"
  [ -f "$f" ] || die "Invoice template not found at $f"
  say "Opening $f"
  case "$OSTYPE" in
    darwin*) open "$f" ;;
    linux*)  xdg-open "$f" >/dev/null 2>&1 || die "xdg-open not available — open $f manually" ;;
    *)       die "Unknown OS — open $f manually" ;;
  esac
}

# ---- dispatch ----
cmd="${1:-help}"
shift || true

case "$cmd" in
  dev|serve|s)        cmd_dev "$@" ;;
  build|b)            cmd_build "$@" ;;
  preview|p)          cmd_preview "$@" ;;
  clean)              cmd_clean "$@" ;;
  check)              cmd_check "$@" ;;
  invoice|inv)        cmd_invoice "$@" ;;
  install|setup)      cmd_install "$@" ;;
  help|-h|--help|"")  cmd_help ;;
  *)                  printf '%s✗%s unknown command: %s\n\n' "$c_red" "$c_reset" "$cmd" >&2; cmd_help; exit 1 ;;
esac
