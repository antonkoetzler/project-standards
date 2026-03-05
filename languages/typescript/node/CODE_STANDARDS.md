# TypeScript / Node.js Code Standards

Documentation is for engineers and AI: key points, behavior, intent; avoid long prose.

Extends the TypeScript general standards. Node.js-specific rules below take precedence.

## Project structure

```
src/
  core/
    errors/       # Typed error classes
    middleware/   # Express/Fastify middleware
    config/       # Environment config (validated at startup)
  features/
    <feature>/
      index.ts
      <feature>.controller.ts   # HTTP layer — parse request, call service, format response
      <feature>.service.ts      # Business logic — no HTTP concerns
      <feature>.repository.ts   # Data access — no business logic
      <feature>.types.ts
      <feature>.test.ts
  main.ts
```

## Naming conventions

- Files: kebab-case. Classes: PascalCase. Functions/vars: camelCase.
- Suffix: `Controller`, `Service`, `Repository`, `Middleware`, `Error`.
- No `I` prefix on interfaces.

## Code style

- **Formatter:** Prettier. **Linter:** ESLint with `typescript-eslint` strict.
- `strict: true` in `tsconfig.json`. No `any`.
- `async`/`await` everywhere. No raw Promise chains. No callbacks unless required by a library.
- All I/O is async. Never block the event loop with sync I/O in production code.
- Explicit return types on all exported functions.

## Key patterns

### Configuration
- Validate all environment variables at startup using a schema (e.g. `zod`, `envalid`).
- Fail fast: if required config is missing, throw on startup — not at runtime.
- No `process.env.FOO` scattered through business logic. Use a typed config object from `core/config/`.

### Error handling
- Define typed error classes in `core/errors/` (e.g. `NotFoundError`, `ValidationError`, `UnauthorizedError`).
- Controller catch blocks map domain errors to HTTP status codes. Services and repositories never import HTTP types.
- Never `throw` a plain string. Never silently catch and discard errors.
- Use a centralized error-handling middleware for HTTP responses.

### Layered architecture
- **Controller:** HTTP only — parse, validate input, call service, format response. No business logic.
- **Service:** Business logic only. No HTTP, no direct DB calls. Calls repository interfaces.
- **Repository:** Data access only. Returns domain objects. No business logic.
- Depend on abstractions: services depend on repository interfaces, not implementations.

### Security
- Validate and sanitize all incoming data at the controller layer (e.g. `zod` schema).
- Parameterized queries only — no string concatenation in SQL.
- Set security headers (Helmet or equivalent). Rate-limit public endpoints.
- Never log secrets, tokens, or PII.

## Testing

- Unit test services and repositories in isolation. Mock repositories in service tests.
- Integration test controllers with a real (or in-memory) DB and an HTTP test client (e.g. `supertest`).
- Do not test implementation details. Test inputs → outputs and side effects.
