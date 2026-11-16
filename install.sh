#!/bin/sh
# Pofyland'ı tek komutla kurar: en son sürümün dmg'sini indirir, /Applications'a kopyalar, açar.
#   curl -fsSL https://raw.githubusercontent.com/konuksev/Pofyland/main/install.sh | sh
# Seçenekler (ortam değişkeni): POFYLAND_VERSION=v1.0.1 (belirli sürüm), POFYLAND_DEST=~/Applications, POFYLAND_NO_OPEN=1
# sudo istemez; yalnızca uygulama klasörüne yazar. Kaldırmak için: Pofyland menüsü → Kaldır.
set -eu
REPO="konuksev/Pofyland"
VERSION="${POFYLAND_VERSION:-latest}"
DEST="${POFYLAND_DEST:-/Applications}"

say()  { printf '%s\n' "$*"; }
fail() { printf '✗ %s\n' "$*" >&2; exit 1; }

[ "$(uname -s)" = Darwin ] || fail "Pofyland yalnızca macOS'ta çalışır."
ver=$(sw_vers -productVersion); major=${ver%%.*}
[ "${major:-0}" -ge 13 ] || fail "macOS 13 ya da üstü gerekli (bu Mac: $ver)."
# Rosetta altındaki terminalde uname -m yanıltır; işlemciye donanımdan bak.
if [ "$(sysctl -n hw.optional.arm64 2>/dev/null || echo 0)" = 1 ]; then ARCH=arm64; else ARCH=x86_64; fi

if [ "$VERSION" = latest ]; then API="https://api.github.com/repos/$REPO/releases/latest"
else API="https://api.github.com/repos/$REPO/releases/tags/$VERSION"; fi
JSON=$(curl -fsSL -H 'Accept: application/vnd.github+json' "$API") || fail "Sürüm bilgisi alınamadı: $API"
TAG=$(printf '%s' "$JSON" | grep -o '"tag_name": *"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
URL=$(printf '%s' "$JSON" | grep -o '"browser_download_url": *"[^"]*\.dmg"' | sed 's/.*"\(https[^"]*\)"$/\1/' | grep -- "-$ARCH\.dmg" | head -1)
[ -n "$URL" ] || fail "Sürüm $TAG içinde $ARCH için dmg yok. https://github.com/$REPO/releases"

say "Pofyland $TAG ($ARCH) indiriliyor…"
TMP=$(mktemp -d); MNT="$TMP/mnt"
cleanup() { hdiutil detach -quiet "$MNT" 2>/dev/null || true; rm -rf "$TMP"; }
trap cleanup EXIT
curl -fL --progress-bar -o "$TMP/Pofyland.dmg" "$URL"
hdiutil attach -quiet -nobrowse -readonly -mountpoint "$MNT" "$TMP/Pofyland.dmg" >/dev/null
[ -d "$MNT/Pofyland.app" ] || fail "dmg içinde Pofyland.app bulunamadı."

mkdir -p "$DEST" 2>/dev/null || true
[ -w "$DEST" ] || { DEST="$HOME/Applications"; mkdir -p "$DEST"; say "/Applications yazılabilir değil, $DEST kullanılıyor."; }
if pgrep -xq PofyBar; then say "Çalışan Pofyland kapatılıyor…"; pkill -x PofyBar || true; sleep 1; fi
rm -rf "$DEST/Pofyland.app"
ditto "$MNT/Pofyland.app" "$DEST/Pofyland.app"
hdiutil detach -quiet "$MNT" >/dev/null 2>&1 || true
# Uygulama henüz Apple imzalı değil; karantina damgası kalksın ki Gatekeeper ilk açılışı engellemesin.
xattr -dr com.apple.quarantine "$DEST/Pofyland.app" 2>/dev/null || true

say "✓ Pofyland $TAG kuruldu: $DEST/Pofyland.app"
if command -v claude >/dev/null 2>&1; then say "✓ Claude Code bulundu; ilk açılışta eklenti kendiliğinden kurulur."
else say "! Claude Code (claude) bulunamadı: https://claude.com/claude-code — kurunca Pofyland menüsünden eklentiyi kurabilirsin."; fi
[ -n "${POFYLAND_NO_OPEN:-}" ] || open "$DEST/Pofyland.app"
