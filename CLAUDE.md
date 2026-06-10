# CLAUDE.md

Guidance for working in this repository.

## What this is

`org-babel` is a pure-Nix implementation of `org-babel-tangle`.
Given an Org string, it extracts source blocks in a specified language.
It is used by [emacs-twist](https://github.com/emacs-twist) to tangle Emacs
Lisp configurations from Org files at build time.

Public API (exported via `flake.nix` under `lib`):

- `tangleOrgBabel { languages; transformLines; } orgString` — returns a string
- `tangleOrgBabelFile name path options` — writes output to a derivation
- `excludeHeadlines`, `matchOrgTag`, `matchOrgHeadline` — predicate helpers

`processLines` is a deprecated alias for `transformLines`.

## Fork / branch model

This is a fork of `emacs-twist/org-babel`.

- **`master`** — a pure mirror of `upstream/master`. Do **not** commit here;
  only fast-forward it from upstream.
- **`develop`** — personal integration branch carrying all local changes.
  Rebase onto `master` when upstream moves.
- **topic branches** (`fix/...`, `feat/...`, `docs/...`) — branched off
  `master`, one change each, kept PR-ready for upstream. Merged into `develop`.

`upstream` remote: `https://github.com/emacs-twist/org-babel`.

Avoid repo-wide reformatting on `develop` — it would conflict on every rebase
against `master`.

## Layout

| Path        | Contents                                               |
|-------------|--------------------------------------------------------|
| `nix/`      | Library implementation (parsers, tangler, helpers)     |
| `test/`     | Test flake and test Org files                          |
| `flake.nix` | Flake outputs: `lib`, `overlays.default`               |

## Commands

Unit tests (pure evaluation):

```sh
nix-instantiate --strict --eval --json test/test.nix | jq
```

Integration test (builds a derivation from a test Org file):

```sh
nix build ./test#checks.x86_64-linux.build
```

Inspect flake outputs:

```sh
nix flake show
```

## Conventions

- Nix files follow `nixfmt-rfc-style`.
- The `nix/` directory contains one function per file; `nix/default.nix`
  assembles the public `lib` attrset.
