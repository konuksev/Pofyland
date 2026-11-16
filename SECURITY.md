# Security policy

Pofyland runs entirely on your Mac. Its server listens on `127.0.0.1:7433` only; the phone reaches it over your own
Tailscale network. It can answer permission prompts for your coding agents, so a hole in it matters. Thank you for looking.

## Supported versions

Only the [latest release](https://github.com/konuksev/Pofyland/releases/latest) gets fixes. Pofyland checks for updates
once a day and updates from its menu (Pofyland menu → **Update**).

| Version | Supported |
| ------- | --------- |
| latest 1.0.x | ✓ |
| older | ✗ |

## Reporting a vulnerability

Please **do not open a public issue** for a security problem.

Report it privately: **Security** tab → [**Report a vulnerability**](https://github.com/konuksev/Pofyland/security/advisories/new).
Only the maintainer sees it.

Helpful to include:
- Pofyland version (Pofyland menu → About) and macOS version
- what an attacker can do, and from where (same Mac, same Wi-Fi, tailnet, the internet)
- steps to reproduce

What to expect: a first reply within 3 days, a fix or a plan within 14 days for confirmed issues, and a published
advisory with credit (if you want it) once the fix is out.

## Scope

In scope: the Pofyland app, its local server, the phone web app, push notifications, the Claude Code plugin it installs,
and `install.sh` / `doctor.sh` in this repo.

Out of scope: Claude Code, Codex, Antigravity and Tailscale themselves (report to their makers), and attacks that need
an attacker who already controls your macOS user account.

## Known limits

- The app is not yet signed with an Apple Developer ID; `install.sh` removes the quarantine flag. Signing and
  notarization are planned.
- Keys live under `~/Library/Application Support/PofyAqua`, readable only by your user account.
- The only official source is this repo (`github.com/konuksev/Pofyland`) and its releases. Install scripts or builds
  from forks and other copies are not maintained or reviewed; a changed `install.sh` there could install anything.
