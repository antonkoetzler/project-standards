# Go Rules

## Structure

- `cmd/<app>/main.go` — entry point only (wire + run). `internal/<feature>/` — handler, service, repository, model.
- `pkg/` only for genuinely external-reusable code. No `utils/` or `helpers/` packages.
- `internal/` enforces package privacy.

## Code style

- `gofmt` on save. `golangci-lint` (errcheck, staticcheck, gosimple, unused). All code passes `go vet`.
- `goimports`: stdlib / external / internal — separated by blank lines.

## Patterns

- **Errors:** Check every error. Wrap with `fmt.Errorf("context: %w", err)`. Sentinel errors for caller-handled cases. No `panic` in libraries. No `log.Fatal` outside `main`.
- **Interfaces:** Define at consumption site. Accept interfaces, return concretes. Keep interfaces small (one method preferred).
- **Context:** First param of all I/O functions. Never stored in structs. No `context.Background()` in library code.
- **Concurrency:** Channels for communication. Mutexes for shared state. No goroutine leaks.
- **DI:** Wire in `main.go`. No `init()` for DI. No global registries.

## Naming

- Packages: short, lowercase, single word. No underscores.
- Errors: `ErrNotFound` (sentinel), `NotFoundError` (type).
- Interfaces: `-er` suffix for single-behavior (`Storer`, `Reader`).
- Receivers: short abbreviation, consistent across all methods.

## Testing

- Co-located `_test.go`. `package <name>_test` for black-box. Table-driven with `t.Run`.
- Interfaces for mocking (mockgen/moq). `go test -race ./...` in CI.
