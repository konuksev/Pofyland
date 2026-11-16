# Contributing to Pofyland

Thanks for wanting to help. This repo holds the releases, the install scripts and the docs; the app's source lives in a
separate repo. That still leaves plenty to do here.

## Ways to help

- **Report a bug:** [open a bug report](https://github.com/konuksev/Pofyland/issues/new?template=bug_report.yml).
  First run the doctor and paste its output; it changes nothing and contains no secrets:
  ```sh
  curl -fsSL https://raw.githubusercontent.com/konuksev/Pofyland/main/doctor.sh | sh
  ```
- **Suggest an idea:** [open a feature request](https://github.com/konuksev/Pofyland/issues/new?template=feature_request.yml),
  or start a thread in [Discussions](https://github.com/konuksev/Pofyland/discussions) if it is still fuzzy.
- **Ask a question or show your sea:** [Discussions](https://github.com/konuksev/Pofyland/discussions).
- **Improve the docs or the scripts:** pull requests are welcome (see below).
- **Security problems:** never in a public issue; see [SECURITY.md](SECURITY.md).

## Pull requests

What can change here: `README.md`, `README.tr.md` (keep both languages in step), `docs/`, `install.sh`, `doctor.sh`.

1. Fork, make a branch, keep the change small and about one thing.
2. The scripts are POSIX `sh` and must run on a stock Mac (macOS 13+). No new dependencies, no `sudo`.
   `doctor.sh` must stay read-only unless `--fix` is given.
3. Check your script with `sh -n install.sh doctor.sh` and, if you have it, `shellcheck`. CI runs both and does a real
   install on a macOS runner.
4. Describe what you changed and how you tried it.

## Language

English or Turkish, both are fine in issues and pull requests.

By contributing you agree that your contribution is licensed under the [MIT License](LICENSE) of this repo, and that
you follow the [code of conduct](CODE_OF_CONDUCT.md).
