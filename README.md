# myoro-project-standards

Language, framework, and practice standards for every major AI coding tool. Run the installer in your project root to generate config files for Claude Code, Cursor, Windsurf, and GitHub Copilot.

## Install

**Unix / macOS / Git Bash:**
```sh
bash <(curl -fsSL https://raw.githubusercontent.com/antonkoetzler/myoro-project-standards/main/install.sh)
```

**Windows PowerShell:**
```powershell
irm https://raw.githubusercontent.com/antonkoetzler/myoro-project-standards/main/install.ps1 | iex
```

Run from your project root. The script is interactive — no flags needed.

**Sync** (re-fetch standards without repeating the interactive setup):
```sh
# Unix
bash <(curl -fsSL .../install.sh) --sync

# PowerShell
$env:SYNC = "1"; irm .../install.ps1 | iex
```

**Dry run** (preview without writing files):
```sh
# Unix
bash <(curl -fsSL .../install.sh) --dry-run

# PowerShell
$env:DRY_RUN = "1"; irm .../install.ps1 | iex
```

## What the installer does

1. **Step 1 — Languages:** select languages and frameworks
2. **Step 2 — Practices:** select engineering practices (git, security, testing, AI ownership, etc.)
3. **Step 3 — AI tools:** select which tools to configure
4. Confirms the target directory and warns about files that will be overwritten
5. Fetches standards and writes them into your project

**All content goes to `docs/myoro-project-standards/` — one place, no duplication:**

```
docs/
  myoro-project-standards/
    dart_flutter.md       <- managed by installer (always overwritten on re-run)
    typescript.md
    git.md
    security.md
    ai.md
    .manifest             <- tracks selections for --sync
    ...
  custom/
    README.md             <- created once, never overwritten
    dart_flutter.md       <- YOUR file — installer never touches this folder
```

**AI tool configs reference `docs/myoro-project-standards/` — they contain no rules themselves:**

| Tool | Files created |
|------|--------------|
| Claude Code / Antigravity | `CLAUDE.md` — imports `@docs/myoro-project-standards/<name>.md` |
| Cursor | `.cursor/rules/<name>.mdc` — frontmatter + `@docs/myoro-project-standards/<name>.md` |
| Windsurf | `.windsurf/rules/<name>.md` — frontmatter + `@docs/myoro-project-standards/<name>.md` |
| GitHub Copilot | `.github/copilot-instructions.md` + `.github/instructions/<name>.instructions.md` |

**Re-running the installer or using `--sync` always overwrites** managed files. `docs/custom/` is your permanent zone — the installer never touches it.

## Sync

After the first install, a `.manifest` file is saved in `docs/myoro-project-standards/`. Running the installer with `--sync` reads this manifest and re-fetches all previously selected standards and regenerates tool configs — no interactive prompts needed.

This is the recommended way to update standards. Do not manually edit files in `docs/myoro-project-standards/`.

## What's in this repo

```
practices/
  ai/             AI code ownership — AI owns the dev lifecycle
  engineering/    SOLID, DRY/YAGNI/KISS, naming, functions, uniformity
  workflow/       Makefile task runner, DAP debugging, no IDE configs, documentation
  git/            Conventional Commits, branch naming, PR rules, merge policy
  api/            REST semantics, URI conventions, status codes, error format (RFC 7807)
  security/       Secrets, input validation, OWASP Top 10, dependencies, headers
  sql/            SQL style, migrations, N+1, indexes, transactions, connection pooling
  design/         Visual hierarchy, typography, color, spacing, UX patterns, accessibility
  observability/  Structured logging, metrics (four golden signals), distributed tracing
  testing/        Test pyramid, unit/integration/E2E strategy, naming, coverage

languages/
  css/tailwind/   Tailwind CSS + shadcn/ui
  dart/           Dart language
  dart/flutter/   Flutter framework
  typescript/     TypeScript (general)
  typescript/react/ TypeScript / React
  typescript/node/  TypeScript / Node.js
  javascript/     JavaScript
  python/         Python
  go/             Go
  rust/           Rust
  java/           Java
  c/              C
  cpp/            C++
  csharp/         C#
```

Each folder has two files:
- `CODE_STANDARDS.md` — full documentation (for human reading and project wikis)
- `RULES.md` — condensed version injected into AI tool configs via `docs/myoro-project-standards/`

## docs/custom/

After installing, a `docs/custom/README.md` is created explaining the pattern. Create `docs/custom/<name>.md` to add project-specific rules on top of upstream standards. AI tool configs include a comment referencing the expected path.

Safe names match `docs/myoro-project-standards/` file names:
- `languages/dart/flutter` -> `dart_flutter` -> `docs/myoro-project-standards/dart_flutter.md` / `docs/custom/dart_flutter.md`
- `practices/git` -> `git` -> `docs/myoro-project-standards/git.md` / `docs/custom/git.md`
