# Go Code Standards

Documentation is for engineers and AI: key points, behavior, intent; avoid long prose.

## Project structure

```
cmd/
  <app>/
    main.go          # Entry point only — wire dependencies, call Run()
internal/
  <feature>/
    handler.go       # HTTP/gRPC handler
    service.go       # Business logic
    repository.go    # Data access interface + implementation
    model.go         # Domain types
    service_test.go
pkg/
  <shared>/          # Importable by external packages (keep minimal)
go.mod
go.sum
```

- `internal/` enforces package privacy — only this module can import it.
- `pkg/` only for code genuinely reusable by other modules.
- No `utils/` or `helpers/` packages — name packages by what they do, not what they are.

## Naming conventions

- **Packages:** short, lowercase, single word (`user`, `auth`, `storage`). No underscores.
- **Files:** snake_case (`user_service.go`, `user_service_test.go`).
- **Exported:** PascalCase. **Unexported:** camelCase.
- **Interfaces:** suffix with `-er` when it describes one behavior (`Reader`, `Storer`). No `I` prefix.
- **Error vars:** `ErrNotFound`, `ErrUnauthorized`. **Error types:** `ValidationError`, `NotFoundError`.
- **Receivers:** short abbreviation of type name (`u *User`, `s *Service`). Consistent across all methods.

## Code style

- **Formatter:** `gofmt` (run on save). No alternatives.
- **Linter:** `golangci-lint` with at minimum `errcheck`, `staticcheck`, `gosimple`, `unused`.
- All code must pass `go vet`.
- No unused imports, no unused variables (Go enforces this).
- `goimports` for import grouping: stdlib, external, internal — separated by blank lines.

## Key patterns

### Error handling
- Errors are values. Check every error. Do not ignore with `_`.
- Wrap errors with context: `fmt.Errorf("user service: get user: %w", err)`.
- Define sentinel errors (`var ErrNotFound = errors.New("not found")`) for errors callers must handle.
- No `panic` in library code. Reserve `panic` for programmer errors (nil pointer dereference, etc.).
- Never use `log.Fatal` or `os.Exit` outside `main`.

### Interfaces
- Define interfaces where they are consumed, not where they are implemented.
- Accept interfaces, return concrete types.
- Keep interfaces small — prefer one-method interfaces.

### Context
- Pass `context.Context` as the first parameter to all functions that do I/O or may be cancelled.
- Never store context in a struct. Never use `context.Background()` in library code.

### Concurrency
- Use channels for communication. Use mutexes for shared state.
- No goroutine leaks — always ensure goroutines can exit.
- Document goroutine ownership and lifetime.

### Dependency injection
- Wire dependencies in `main.go` or a `wire.go` file. No `init()` functions for DI.
- Prefer explicit construction over global registries.

## Testing

- `_test.go` co-located. Use `package <name>_test` for black-box tests; `package <name>` only when testing unexported internals.
- Table-driven tests with `t.Run` for multiple cases.
- Use interfaces for mocking. Generate mocks with `mockgen` or `moq`.
- `go test -race ./...` in CI to catch race conditions.
