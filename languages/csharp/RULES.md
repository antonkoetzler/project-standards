# C# Rules

## Structure

- Layered per feature: `Controller`, `Service`, `IRepository` + `Repository`, `Models/`.
- `Core/Errors/` for exception hierarchy. `Core/Config/` for typed options.
- File-scoped namespaces matching folder structure.

## Code style

- `dotnet format` on save. Roslyn analyzers (Microsoft + SonarAnalyzer).
- .NET 8+ minimum. `<Nullable>enable</Nullable>` in all project files. File-scoped namespaces.
- `var` for obvious types. No `#pragma warning disable` without documented reason.
- Private fields: `_camelCase`. Constants: PascalCase.

## Patterns

- **Records:** `record`/`record struct` for DTOs and value objects. `init`-only setters for semi-mutable.
- **Nullable:** Nullable enabled everywhere. No `!` without justification. Validate at public boundaries.
- **Async:** `async Task<T>` always. No `async void` (except event handlers). No `.Result`/`.Wait()`. `CancellationToken` as last param on all async public methods.
- **Errors:** Custom hierarchy (`AppException` base). Typed exceptions. Global exception middleware / `IExceptionHandler`. `Result<T>` for expected failures.
- **DI:** Constructor injection only. No service locator. Interfaces (`I<Name>`) for services/repos. Register via extension methods in `Program.cs`.

## Testing

- xUnit + FluentAssertions + Moq/NSubstitute. Unit: mock repos. Integration: `WebApplicationFactory` + Testcontainers.
- `[Theory]` + `[InlineData]` for parameterized. Test behaviour, not implementation.
