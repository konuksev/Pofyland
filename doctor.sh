#!/bin/sh
# Pofyland doctor: finds out why Pofys don't show up on this Mac. Changes nothing (except with --fix).
#   curl -fsSL https://raw.githubusercontent.com/konuksev/Pofyland/main/doctor.sh | sh
#   … | sh -s -- --fix     installs the Claude plugin if it is missing (claude plugin marketplace add + install)
# Copy and send the output; it contains nothing secret (paths and versions only).
set -u
FIX=0; [ "${1:-}" = "--fix" ] && FIX=1
ok()   { printf '  ✓ %s\n' "$*"; }
bad()  { printf '  ✗ %s\n' "$*"; }
note() { printf '    %s\n' "$*"; }
sh_find() { /bin/zsh -l -i -c "whence -p $1" 2>/dev/null </dev/null | grep "^/.*/$1\$" | head -1; }

printf 'Pofyland doctor · %s · macOS %s · %s\n' "$(date '+%Y-%m-%d %H:%M')" "$(sw_vers -productVersion)" "$(uname -m)"

printf '\nApp\n'
APP=/Applications/Pofyland.app; [ -d "$APP" ] || APP="$HOME/Applications/Pofyland.app"
if [ -d "$APP" ]; then ok "$APP · version $(defaults read "$APP/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null)"
else bad "Pofyland.app not found. Install: curl -fsSL https://raw.githubusercontent.com/konuksev/Pofyland/main/install.sh | sh"; fi
if pgrep -xq PofyBar; then ok "Pofyland is running"; else bad "Pofyland is not running: open it from Applications"; fi
[ -d "$APP/Contents/Resources/plugin/pofy-live" ] && ok "Claude plugin is bundled in the app" || bad "no plugin inside the app (broken copy: reinstall)"

printf '\nPofyland server (background)\n'
if launchctl print "gui/$(id -u)/com.poflow.pofy-aqua" >/dev/null 2>&1; then ok "LaunchAgent loaded (com.poflow.pofy-aqua)"
else bad "LaunchAgent not loaded: quit and reopen Pofyland once; install log below"; fi
ST=$(curl -fsS -m 3 http://127.0.0.1:7433/state.json 2>/dev/null)
if [ -n "$ST" ]; then ok "server responds (127.0.0.1:7433)"
else bad "server does not respond (127.0.0.1:7433). Log: ~/Library/Logs/pofy-aqua.log"; fi

printf '\nSession records (/tmp/pofy-peers)\n'
if [ -d /tmp/pofy-peers ]; then
  n=$(find /tmp/pofy-peers -name '*.json' -mmin -10 2>/dev/null | wc -l | tr -d ' ')
  [ "$n" -gt 0 ] && ok "$n session records written in the last 10 minutes" || bad "no records written in the last 10 minutes: no open session, or the plugin is not running"
  for f in $(find /tmp/pofy-peers -name '*.json' -mmin -10 2>/dev/null | head -8); do
    a=$(grep -o '"agent": *"[^"]*"' "$f" | head -1 | sed 's/.*"\([^"]*\)"$/\1/'); note "$(basename "$f") · ${a:-claude}"
  done
else bad "/tmp/pofy-peers missing: no session has written a record (plugin not installed, or the session was started before the plugin was installed)"; fi

printf '\nClaude Code and plugin\n'
CL=$(sh_find claude)
if [ -n "$CL" ]; then ok "claude: $CL · $("$CL" --version 2>/dev/null | head -1)"
else bad "no claude command. Install: curl -fsSL https://claude.ai/install.sh | bash  (the Claude desktop app alone is not enough: the plugin is installed with this command)"; fi
[ -e "$HOME/.claude/pofyland/pofy-live" ] && ok "~/.claude/pofyland (plugin copy) present" || bad "~/.claude/pofyland missing: 'Install plugin' in the setup guide never ran"
if [ -n "$CL" ]; then
  ML=$("$CL" plugin marketplace list 2>/dev/null)
  printf '%s' "$ML" | grep -q pofyland && ok "marketplace 'pofyland' added" || bad "marketplace 'pofyland' not added"
  PL=$("$CL" plugin list 2>/dev/null)
  if printf '%s' "$PL" | grep -q "pofy-live@pofyland"; then ok "plugin installed: pofy-live@pofyland"
    printf '%s' "$PL" | grep -iq "disabled" && bad "plugin looks disabled: claude plugin enable pofy-live@pofyland"
  else bad "plugin not installed (pofy-live@pofyland)"; fi
fi
grep -q pofy-live "$HOME/.claude/plugins/installed_plugins.json" 2>/dev/null && ok "pofy-live listed in installed_plugins.json" || bad "pofy-live not in installed_plugins.json"

if [ "$FIX" = 1 ] && [ -n "$CL" ]; then
  printf '\nRepair (--fix)\n'
  if [ ! -e "$HOME/.claude/pofyland" ] && [ -d "$APP/Contents/Resources/plugin" ]; then
    mkdir -p "$HOME/.claude" && cp -R "$APP/Contents/Resources/plugin" "$HOME/.claude/pofyland" && ok "plugin copied: ~/.claude/pofyland"
  fi
  "$CL" plugin marketplace list 2>/dev/null | grep -q pofyland || { "$CL" plugin marketplace add "$HOME/.claude/pofyland" && ok "marketplace added"; }
  "$CL" plugin install pofy-live@pofyland && ok "plugin installed" || bad "plugin install failed (see the error above)"
  note "Now quit and reopen your Claude sessions and the Claude app: new sessions will appear in the sea."
fi

printf '\nCodex and Antigravity (optional)\n'
CX=$(sh_find codex); [ -n "$CX" ] && ok "codex: $CX" || note "no codex (for a Codex Pofy: npm i -g @openai/codex or the ChatGPT app)"
[ -x /Applications/ChatGPT.app/Contents/Resources/codex-cli/bin/codex ] && ok "Codex from the ChatGPT app present"
AG=$(sh_find agy); [ -n "$AG" ] && ok "agy: $AG" || note "no agy (an Antigravity Pofy needs Antigravity installed)"
[ -d "$HOME/.gemini/antigravity" ] && ok "Antigravity data present (~/.gemini/antigravity)"

printf '\nLogs (last lines)\n'
for L in pofy-aqua-install.log pofy-aqua.log; do
  if [ -f "$HOME/Library/Logs/$L" ]; then printf '  — %s\n' "$L"; tail -n 8 "$HOME/Library/Logs/$L" | cut -c1-160 | sed 's/^/    /'; else note "$L missing"; fi
done
printf '\nDone. Send this output as is.\n'
