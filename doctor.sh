#!/bin/sh
# Pofyland tanı: bu Mac'te Pofy'lerin neden gelmediğini bulur. Hiçbir şeyi değiştirmez (--fix hariç).
#   curl -fsSL https://raw.githubusercontent.com/konuksev/Pofyland/main/doctor.sh | sh
#   … | sh -s -- --fix     Claude eklentisi eksikse kurar (claude plugin marketplace add + install)
# Çıktıyı kopyalayıp gönder; gizli bir şey içermez (yollar ve sürümler).
set -u
FIX=0; [ "${1:-}" = "--fix" ] && FIX=1
ok()   { printf '  ✓ %s\n' "$*"; }
bad()  { printf '  ✗ %s\n' "$*"; }
note() { printf '    %s\n' "$*"; }
sh_find() { /bin/zsh -l -i -c "whence -p $1" 2>/dev/null </dev/null | grep "^/.*/$1\$" | head -1; }

printf 'Pofyland tanı · %s · macOS %s · %s\n' "$(date '+%Y-%m-%d %H:%M')" "$(sw_vers -productVersion)" "$(uname -m)"

printf '\nUygulama\n'
APP=/Applications/Pofyland.app; [ -d "$APP" ] || APP="$HOME/Applications/Pofyland.app"
if [ -d "$APP" ]; then ok "$APP · sürüm $(defaults read "$APP/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null)"
else bad "Pofyland.app yok. Kur: curl -fsSL https://raw.githubusercontent.com/konuksev/Pofyland/main/install.sh | sh"; fi
if pgrep -xq PofyBar; then ok "Pofyland çalışıyor"; else bad "Pofyland açık değil: Applications'tan aç"; fi
[ -d "$APP/Contents/Resources/plugin/pofy-live" ] && ok "uygulamanın içinde Claude eklentisi var" || bad "uygulamanın içinde eklenti yok (bozuk kopya: yeniden kur)"

printf '\nPofyland sunucusu (arka plan)\n'
if launchctl print "gui/$(id -u)/com.poflow.pofy-aqua" >/dev/null 2>&1; then ok "LaunchAgent yüklü (com.poflow.pofy-aqua)"
else bad "LaunchAgent yüklü değil: Pofyland'ı bir kez kapatıp aç; kurulum günlüğü aşağıda"; fi
ST=$(curl -fsS -m 3 http://127.0.0.1:7433/state.json 2>/dev/null)
if [ -n "$ST" ]; then ok "sunucu cevap veriyor (127.0.0.1:7433)"
else bad "sunucu cevap vermiyor (127.0.0.1:7433). Günlük: ~/Library/Logs/pofy-aqua.log"; fi

printf '\nOturum kayıtları (/tmp/pofy-peers)\n'
if [ -d /tmp/pofy-peers ]; then
  n=$(find /tmp/pofy-peers -name '*.json' -mmin -10 2>/dev/null | wc -l | tr -d ' ')
  [ "$n" -gt 0 ] && ok "son 10 dakikada yazılmış $n oturum kaydı var" || bad "son 10 dakikada yazılmış kayıt yok: açık oturum yok ya da eklenti çalışmıyor"
  for f in $(find /tmp/pofy-peers -name '*.json' -mmin -10 2>/dev/null | head -8); do
    a=$(grep -o '"agent": *"[^"]*"' "$f" | head -1 | sed 's/.*"\([^"]*\)"$/\1/'); note "$(basename "$f") · ${a:-claude}"
  done
else bad "/tmp/pofy-peers yok: hiçbir oturum kayıt yazmamış (eklenti kurulu değil ya da oturum eklenti kurulduktan sonra açılmadı)"; fi

printf '\nClaude Code ve eklenti\n'
CL=$(sh_find claude)
if [ -n "$CL" ]; then ok "claude: $CL · $("$CL" --version 2>/dev/null | head -1)"
else bad "claude komutu yok. Kur: curl -fsSL https://claude.ai/install.sh | bash  (Claude masaüstü uygulaması tek başına yetmez: eklenti bu komutla kurulur)"; fi
[ -e "$HOME/.claude/pofyland/pofy-live" ] && ok "~/.claude/pofyland (eklenti kopyası) var" || bad "~/.claude/pofyland yok: sihirbazdaki 'Eklentiyi kur' hiç çalışmamış"
if [ -n "$CL" ]; then
  ML=$("$CL" plugin marketplace list 2>/dev/null)
  printf '%s' "$ML" | grep -q pofyland && ok "marketplace 'pofyland' ekli" || bad "marketplace 'pofyland' ekli değil"
  PL=$("$CL" plugin list 2>/dev/null)
  if printf '%s' "$PL" | grep -q "pofy-live@pofyland"; then ok "eklenti kurulu: pofy-live@pofyland"
    printf '%s' "$PL" | grep -iq "disabled\|kapalı" && bad "eklenti kapalı görünüyor: claude plugin enable pofy-live@pofyland"
  else bad "eklenti kurulu değil (pofy-live@pofyland)"; fi
fi
grep -q pofy-live "$HOME/.claude/plugins/installed_plugins.json" 2>/dev/null && ok "installed_plugins.json içinde pofy-live var" || bad "installed_plugins.json içinde pofy-live yok"

if [ "$FIX" = 1 ] && [ -n "$CL" ]; then
  printf '\nOnarım (--fix)\n'
  if [ ! -e "$HOME/.claude/pofyland" ] && [ -d "$APP/Contents/Resources/plugin" ]; then
    mkdir -p "$HOME/.claude" && cp -R "$APP/Contents/Resources/plugin" "$HOME/.claude/pofyland" && ok "eklenti kopyalandı: ~/.claude/pofyland"
  fi
  "$CL" plugin marketplace list 2>/dev/null | grep -q pofyland || { "$CL" plugin marketplace add "$HOME/.claude/pofyland" && ok "marketplace eklendi"; }
  "$CL" plugin install pofy-live@pofyland && ok "eklenti kuruldu" || bad "eklenti kurulamadı (yukarıdaki hata)"
  note "Şimdi açık Claude oturumlarını ve Claude uygulamasını kapatıp yeniden aç: yeni oturumlar denize gelir."
fi

printf '\nCodex ve Antigravity (isteğe bağlı)\n'
CX=$(sh_find codex); [ -n "$CX" ] && ok "codex: $CX" || note "codex yok (Codex Pofy'si için: npm i -g @openai/codex ya da ChatGPT uygulaması)"
[ -x /Applications/ChatGPT.app/Contents/Resources/codex-cli/bin/codex ] && ok "ChatGPT uygulamasının Codex'i var"
AG=$(sh_find agy); [ -n "$AG" ] && ok "agy: $AG" || note "agy yok (Antigravity Pofy'si için Antigravity kurulu olmalı)"
[ -d "$HOME/.gemini/antigravity" ] && ok "Antigravity verisi var (~/.gemini/antigravity)"

printf '\nGünlükler (son satırlar)\n'
for L in pofy-aqua-install.log pofy-aqua.log; do
  if [ -f "$HOME/Library/Logs/$L" ]; then printf '  — %s\n' "$L"; tail -n 8 "$HOME/Library/Logs/$L" | cut -c1-160 | sed 's/^/    /'; else note "$L yok"; fi
done
printf '\nBitti. Bu çıktıyı olduğu gibi gönder.\n'
