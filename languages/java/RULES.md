# Java Rules

## Structure

- Layered per feature: `Controller`, `Service`, `Repository` (interface + impl), `model/`.
- `core/error/` for custom exception hierarchy. `core/config/` for configuration.

## Code style

- `google-java-format` on save. Checkstyle + PMD for static analysis.
- Java 17+ minimum. Records, sealed classes, pattern matching, text blocks.
- `var` for obvious local types only. No raw types. No `null` in public APIs — use `Optional<T>`.

## Patterns

- **Records:** Use `record` for immutable data. `sealed` classes for sum types.
- **Errors:** Custom exception hierarchy (`AppException` base). Typed exceptions (`NotFoundException`, etc.). No catching `Exception`/`Throwable` except at boundaries. Global `@ControllerAdvice` for HTTP mapping.
- **DI:** Constructor injection only — never field `@Autowired`. Interfaces for services/repositories.
- **Collections:** Stream API + `Optional`. `List.of()` / `Map.of()` for immutable. No nulls in collections.

## Testing

- JUnit 5 + Mockito + AssertJ. Unit test services (mock repos). Integration: `@SpringBootTest` + Testcontainers.
- No `@SpringBootTest` in unit tests.
