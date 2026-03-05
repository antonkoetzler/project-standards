# Development Workflow

## Makefile

Every project has a `Makefile`. No committed VSCode `tasks.json` or IDE run configs.

Common target categories: run, test, build, clean, code generation, debug, lint, format, help. Name targets to fit the project.

Include a help target (self-documenting `##` comment pattern).

## DAP Debugging

- A debug target starts the app in debug/attach mode; prints port/URL to stdout.
- IDEs connect via DAP adapter. No IDE debug configs committed.
- Do not commit `.vscode/launch.json`, `.idea/runConfigurations/`, or similar.

## No Committed IDE Configs

- No `.vscode/`, `.idea/`, `*.suo`, `*.user`, `*.swp` in the repo.
- Add to `.gitignore`. The Makefile is the universal project interface.

## Documentation

- Decisions in `docs/decisions/` (ADR format). Setup in `README.md`.
- Nothing in external wikis that isn't also in the repo.
- Key points, behaviour, intent. No long prose. Document the *why*.
