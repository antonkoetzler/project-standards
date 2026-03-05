# Dart Rules

## Structure

- Feature-first: `lib/src/features/<feature>/`. `<package>.dart` exports public API only.
- `exports.dart` within feature folders to re-export public classes.
- One object per file. No `part`/`part of` outside Flutter widget patterns.

## Code style

- `dart format .` (built-in, 120 line length recommended). `dart analyze` with `lints: recommended` or `lints: strict`.
- FVM for SDK version management (`.fvmrc`). Dart 3.0+ minimum. Null safety required.
- `final` for non-reassigning locals. `const` everywhere possible. Constants use `k` prefix: `kMaxRetries`.
- `_` for unused params (reuse for multiple: `(_, __, state)`). No magic numbers.

## Patterns

- **Null safety:** `T?` only when null is meaningful. No `!` without a guard above it. Use `??`, `?.`, `??=`.
- **Async:** `async`/`await` over raw Future chaining. Always close `StreamController`. Never silently ignore a `Future` — use `unawaited()`.
- **Extensions:** `<TypeName>Extension` or descriptive name. One concern per extension.
- **Records (Dart 3+):** Lightweight tuples. Pattern matching in `switch`/`if-case`. Exhaustive switch on sealed classes.
- **Errors:** Typed exception classes. `Result<T>` pattern for expected failures in domain logic. `try`/`catch` at system boundaries only.
- **Type safety:** Avoid `as`/`is` — prefer OOP inheritance and polymorphism. `sealed class` for closed hierarchies.
- **Versioning:** `CHANGELOG.md` + `STAGELOG.md` for pre-release notes. `tool/` directory for shell scripts.

## Testing

- `package:test` + `package:mockito` or `package:mocktail`. Co-located in `test/src/`.
- `group()` for related cases. `setUp`/`tearDown` for shared state.
