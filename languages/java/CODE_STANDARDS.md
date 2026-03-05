# Java Code Standards

Documentation is for engineers and AI: key points, behavior, intent; avoid long prose.

## Project structure

```
src/
  main/
    java/
      com/<org>/<app>/
        core/
          config/
          error/        # Custom exception hierarchy
        features/
          <feature>/
            <Feature>Controller.java
            <Feature>Service.java
            <Feature>Repository.java   # Interface
            <Feature>RepositoryImpl.java
            model/
              <Feature>Record.java     # Java record
              <Feature>Request.java
              <Feature>Response.java
  test/
    java/
      com/<org>/<app>/
        features/
          <feature>/
            <Feature>ServiceTest.java
build.gradle.kts  (or pom.xml)
```

## Naming conventions

- **Packages:** all lowercase, reverse domain (`com.example.app.features.user`).
- **Classes/Interfaces/Records/Enums:** PascalCase.
- **Methods/variables:** camelCase. **Constants:** SCREAMING_SNAKE_CASE.
- **Interfaces:** no `I` prefix. `UserRepository`, not `IUserRepository`.
- **Test classes:** `<Subject>Test` (unit), `<Subject>IT` (integration).

## Code style

- **Formatter:** `google-java-format` (Gradle/Maven plugin). Run on save.
- **Linter:** Checkstyle with Google or project-defined ruleset. PMD for additional static analysis.
- Java 17+ minimum. Use modern features: records, sealed classes, pattern matching, text blocks.
- `var` for obvious local types. Never `var` for non-obvious types or method return types.
- No raw types (`List` instead of `List<String>` is forbidden). Generics everywhere.
- No `null` in public APIs — use `Optional<T>` for optional return values.

## Key patterns

### Records and sealed classes
- Use `record` for immutable data carriers (`UserRecord`, `CreateUserRequest`).
- Use `sealed` classes/interfaces for sum types (exhaustive pattern matching with `switch`).
- No mutable data classes (no public setters on domain objects).

### Error handling
- Define a custom exception hierarchy in `core/error/`. Base: `AppException extends RuntimeException`.
- Use typed exceptions (`NotFoundException`, `ValidationException`, `UnauthorizedException`).
- Never catch `Exception` or `Throwable` except at the outermost boundary.
- No swallowed exceptions: always log or rethrow.
- Global exception handler (e.g. `@ControllerAdvice` in Spring) maps exceptions to responses.

### Dependency injection
- Spring or Guice for DI. No field injection (`@Autowired` on fields). Constructor injection only.
- Keep constructors simple — no logic, just assignment.
- Interfaces for services and repositories. Concrete classes are `@Component`/`@Service`/`@Repository`.

### Streams and collections
- Use `Stream` API and `Optional` idiomatically. Avoid imperative loops for transformations.
- Prefer `List.of()`, `Map.of()` for immutable collections.
- No `null` in collections.

## Testing

- JUnit 5 + Mockito. `@ExtendWith(MockitoExtension.class)` for unit tests.
- Unit test services (mock repositories). Integration test with `@SpringBootTest` + Testcontainers.
- AssertJ for fluent assertions. Avoid plain `assertEquals` from JUnit.
- No `@SpringBootTest` for unit tests — it loads the full context and is slow.
