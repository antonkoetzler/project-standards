# Dart Code Standards

Documentation is for engineers and AI: key points, behavior, intent; avoid long prose.

## Project structure

```
lib/
  src/
    core/             # Shared utilities, DI config, error classes
    features/
      <feature>/
        <feature>_service.dart
        <feature>_repository.dart
        models/
        exports.dart  # Re-exports public API for this feature
  <package>.dart      # Public API barrel — only export what is public
test/
  src/
    features/
      <feature>/
        <feature>_service_test.dart
pubspec.yaml
analysis_options.yaml
```

- One object per file. `<package>.dart` exports only the public API.
- Use `exports.dart` within feature folders to re-export public classes.
- No `part`/`part of` outside of Flutter widget extraction patterns.

## Naming conventions

- **Files:** snake_case (`user_service.dart`). **Classes:** PascalCase. **Functions/vars:** camelCase.
- **Constants:** `k` prefix convention: `const kMaxRetries = 3`. Private: `_kMaxRetries`. Module-level private without prefix: `_camelCase`.
- **Libraries/packages:** snake_case matching the file or package name.
- **Extensions:** `<TypeName>Extension` or descriptive (`StringValidation`, `DateTimeFormatting`).

## Code style

- **Formatter:** `dart format .` (built-in). Configure line length in `analysis_options.yaml` or editor settings (120 recommended).
- **Linter:** `dart analyze` with `analysis_options.yaml` — use `lints: recommended` minimum; `lints: strict` preferred.
- **SDK management:** Use FVM (Flutter Version Manager) for consistent SDK versions across the team. Pin version in `.fvmrc`.
- Dart 3.0+ minimum. Null safety required everywhere.
- `final` for all local variables that don't reassign. `const` wherever possible.
- `_` for unused parameters. Reuse `_` for multiple unused: `(_, __, state)`.
- No magic numbers. Named constants throughout.

## Key patterns

### Null safety
- `T?` only when null is a meaningful value, not as a convenience.
- Never use `!` (null-forgiving) without a null check above it in the same scope.
- Prefer `??`, `?.`, `??=` operators. Use `if (x case final v?)` for pattern-based null guards.
- `late final` for lazy initialization; document why it cannot be initialized in the constructor.

### Async
- `async`/`await` preferred over raw `Future` chaining.
- Use `Stream` for reactive sequences. Always close `StreamController` (use `addError`, `close` in `finally`).
- Never silently ignore a `Future` — `await` it or explicitly call `unawaited()` from `dart:async`.

### Extension methods
- Use to add behavior to types you don't own, or to group related utilities on a type.
- Keep extensions focused — one concern per extension. Don't make a single extension a dumping ground.

### Records and patterns (Dart 3+)
- Use records for lightweight data tuples: `(int, String)` or `({int count, String label})`.
- Pattern matching in `switch`/`if-case` over cascaded if/else or conditional chains.
- Exhaustive switch on sealed classes — never use a fallthrough `default` case when a sealed hierarchy is complete.

### Error handling
- Typed exception classes extending `Exception`. No bare `throw 'string'`.
- Use a `Result<T>` type (e.g. from `package:result_dart`) for expected failures in domain logic.
- `try`/`catch` only at system boundaries; let typed exceptions propagate through business logic.

### Type safety
- Avoid `as` and `is` keywords — prefer OOP inheritance and polymorphism. Type casting/checking usually signals a design issue.
- Use `sealed class` for closed type hierarchies with exhaustive `switch`.

### Versioning
- `CHANGELOG.md` for release history. `STAGELOG.md` for pre-release notes that get merged into CHANGELOG on publish.
- `tool/` directory for shell scripts: `setup.sh`, `format_and_fix.sh`, `deploy.sh`, etc.

## Testing

- Framework: `package:test`. Co-locate: `test/src/features/<feature>/<name>_test.dart`.
- Mocking: `package:mockito` (code-gen) or `package:mocktail` (no codegen).
- Group related tests with `group()`. Shared state via `setUp`/`tearDown`.
- Run `dart test --coverage=coverage/` in CI.
