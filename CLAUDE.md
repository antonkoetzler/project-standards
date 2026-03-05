# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

This is a standards distribution repository — it contains language, framework, and practice standards that get installed into other projects via an interactive CLI installer. It is not a runnable application.

## Architecture

Standards are organized in two top-level directories:

- `languages/` — language and framework-specific standards (dart, typescript, python, etc.)
- `practices/` — cross-cutting practice standards (engineering, git, security, ai, workflow, etc.)

Each folder contains exactly two files:
- `CODE_STANDARDS.md` — full documentation for human reading
- `RULES.md` — condensed version that gets fetched by the installer and placed into `docs/myoro-project-standards/` in target projects

The installer scripts (`install.sh` for Unix, `install.ps1` for PowerShell) are the main entry points. They present an interactive TUI menu, fetch `RULES.md` files from GitHub, write them to `docs/myoro-project-standards/`, save a `.manifest` file for future `--sync` runs, and generate AI tool configs (CLAUDE.md, .cursor/rules/, .windsurf/rules/, .github/instructions/).

## Key conventions

- **docs/myoro-project-standards/** is the managed output directory in target projects (overwritten on re-run or --sync)
- **docs/custom/** is the user's permanent zone (never touched by installer)
- **AI tool configs contain no rules** — they only reference files in `docs/myoro-project-standards/` and `docs/custom/`
- The `.manifest` file in `docs/myoro-project-standards/` stores selections so `--sync` can re-fetch without interactive prompts
- Language/framework docs must not prescribe specific Makefile target names — workflow docs handle Makefile conventions
- `RULES.md` files are what AI tools consume; `CODE_STANDARDS.md` is for wikis and human reading
- Both installers (bash and PowerShell) must stay in sync — changes to one must be reflected in the other

## Working with this repo

There is no build system, test suite, or package manager. Changes are made directly to markdown files and shell scripts.

To test the installer locally:
```sh
bash install.sh --dry-run
```
