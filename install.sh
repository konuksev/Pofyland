#!/bin/sh
# Installs Pofyland with one command: downloads the latest dmg, copies it to /Applications, opens it.
#   curl -fsSL https://raw.githubusercontent.com/konuksev/Pofyland/main/install.sh | sh
# Options (environment variables): POFYLAND_VERSION=v1.0.1 (specific version), POFYLAND_DEST=~/Applications, POFYLAND_NO_OPEN=1
# No sudo; writes only to the Applications folder. To uninstall: Pofyland menu → Uninstall.
set -eu
REPO="konuksev/Pofyland"
VERSION="${POFYLAND_VERSION:-latest}"
DEST="${POFYLAND_DEST:-/Applications}"

say()  { printf '%s\n' "$*"; }
fail() { printf '✗ %s\n' "$*" >&2; exit 1; }

[ "$(uname -s)" = Darwin ] || fail "Pofyland runs on macOS only."
ver=$(sw_vers -productVersion); major=${ver%%.*}
[ "${major:-0}" -ge 13 ] || fail "macOS 13 or later is required (this Mac: $ver)."
# uname -m lies in a Rosetta terminal; ask the hardware instead.
if [ "$(sysctl -n hw.optional.arm64 2>/dev/null || echo 0)" = 1 ]; then ARCH=arm64; else ARCH=x86_64; fi

if [ "$VERSION" = latest ]; then API="https://api.github.com/repos/$REPO/releases/latest"
else API="https://api.github.com/repos/$REPO/releases/tags/$VERSION"; fi
JSON=$(curl -fsSL -H 'Accept: application/vnd.github+json' "$API") || fail "Could not fetch release info: $API"
TAG=$(printf '%s' "$JSON" | grep -o '"tag_name": *"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
URL=$(printf '%s' "$JSON" | grep -o '"browser_download_url": *"[^"]*\.dmg"' | sed 's/.*"\(https[^"]*\)"$/\1/' | grep -- "-$ARCH\.dmg" | head -1)
[ -n "$URL" ] || fail "Release $TAG has no dmg for $ARCH. https://github.com/$REPO/releases"

say "Downloading Pofyland $TAG ($ARCH)…"
TMP=$(mktemp -d); MNT="$TMP/mnt"
cleanup() { hdiutil detach -quiet "$MNT" 2>/dev/null || true; rm -rf "$TMP"; }
trap cleanup EXIT
curl -fL --progress-bar -o "$TMP/Pofyland.dmg" "$URL"
hdiutil attach -quiet -nobrowse -readonly -mountpoint "$MNT" "$TMP/Pofyland.dmg" >/dev/null
[ -d "$MNT/Pofyland.app" ] || fail "Pofyland.app not found inside the dmg."

mkdir -p "$DEST" 2>/dev/null || true
[ -w "$DEST" ] || { DEST="$HOME/Applications"; mkdir -p "$DEST"; say "/Applications is not writable, using $DEST."; }
if pgrep -xq PofyBar; then say "Quitting the running Pofyland…"; pkill -x PofyBar || true; sleep 1; fi
rm -rf "$DEST/Pofyland.app"
ditto "$MNT/Pofyland.app" "$DEST/Pofyland.app"
hdiutil detach -quiet "$MNT" >/dev/null 2>&1 || true
# The app is not Apple-notarized yet; drop the quarantine flag so Gatekeeper doesn't block the first launch.
xattr -dr com.apple.quarantine "$DEST/Pofyland.app" 2>/dev/null || true

say "✓ Pofyland $TAG installed: $DEST/Pofyland.app"
if command -v claude >/dev/null 2>&1; then say "✓ Claude Code found; the plugin installs itself on first launch."
else say "! Claude Code (claude) not found: https://claude.com/claude-code — once it is installed, install the plugin from the Pofyland menu."; fi
[ -n "${POFYLAND_NO_OPEN:-}" ] || open "$DEST/Pofyland.app"
