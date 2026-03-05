# C# Code Standards

Documentation is for engineers and AI: key points, behavior, intent; avoid long prose.

## Project structure

```
src/
  <App>/
    Core/
      Errors/         # Custom exception hierarchy
      Config/         # Typed configuration (IOptions<T>)
    Features/
      <Feature>/
        <Feature>Controller.cs
        <Feature>Service.cs
        I<Feature>Repository.cs
        <Feature>Repository.cs
        Models/
          <Feature>Record.cs     # C# record
          <Feature>Request.cs
          <Feature>Response.cs
    Program.cs         # Minimal API or host builder entry point
tests/
  <App>.Tests/
    Features/
      <Feature>/
        <Feature>ServiceTests.cs
<App>.sln
```

## Naming conventions

- **Namespaces:** match folder structure (`App.Features.User`).
- **Classes/Interfaces/Records/Enums:** PascalCase.
- **Methods/properties:** PascalCase. **Local vars/parameters:** camelCase.
- **Interfaces:** `I` prefix (`IUserRepository`).
- **Constants:** PascalCase (C# convention). `const` for compile-time, `static readonly` for runtime.
- **Private fields:** `_camelCase` prefix.

## Code style

- **Formatter:** `dotnet format` (built-in). Run on save.
- **Linter:** Roslyn analyzers (Microsoft, SonarAnalyzer, StyleCop).
- .NET 8+ minimum. Enable `<Nullable>enable</Nullable>` and `<ImplicitUsings>enable</ImplicitUsings>` in project file.
- File-scoped namespaces (`namespace App.Features.User;`).
- `var` for obvious types. Explicit type for non-obvious.
- No `#pragma warning disable` without a documented reason.

## Key patterns

### Records and immutability
- Use `record` or `record struct` for immutable data transfer objects and value objects.
- Prefer immutable types. Use `init`-only setters when full immutability is not possible.
- No public mutable properties on domain entities exposed in APIs.

### Nullable reference types
- Nullable enabled everywhere. No `!` (null-forgiving operator) without explicit justification.
- `string?` vs `string` is meaningful — use correctly.
- Validate nullable inputs at public API boundaries. Throw `ArgumentNullException` or return appropriate errors.

### Async/await
- `async Task` or `async Task<T>` for all async methods. No `async void` except event handlers.
- `ConfigureAwait(false)` in library code (not in ASP.NET Core controllers).
- Never `.Result` or `.Wait()` on a Task — always `await`.
- `CancellationToken` as the last parameter on all async public methods.

### Error handling
- Custom exception hierarchy in `Core/Errors/`. `AppException` base class.
- Typed exceptions (`NotFoundException`, `ValidationException`, `ConflictException`).
- Global exception middleware (or `IExceptionHandler` in .NET 8+) maps to HTTP responses.
- `Result<T>` pattern (or `OneOf`) for expected failures that are not exceptional.

### Dependency injection
- ASP.NET Core DI container. Constructor injection only — no service locator.
- Register in `Program.cs` or extension methods (`services.AddFeature()`).
- Interfaces for all services and repositories. `I<Name>` naming.
- Scoped for per-request services, Singleton for stateless shared services, Transient sparingly.

## Testing

- xUnit + FluentAssertions + Moq (or NSubstitute).
- Unit test services (mock repositories). Integration test with `WebApplicationFactory<T>` + Testcontainers.
- No `[Fact]` that tests implementation — test behavior through the public API.
- `[Theory]` with `[InlineData]` or `[MemberData]` for parameterized tests.
