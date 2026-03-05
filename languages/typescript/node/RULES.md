# TypeScript / Node.js Rules

Extends TypeScript general rules. Node.js-specific rules take precedence.

## Structure

- Layered per feature: `controller.ts` → `service.ts` → `repository.ts` → `types.ts`.
- `src/core/errors/`, `src/core/config/`, `src/core/middleware/` for shared infrastructure.

## Code style

- `async`/`await` everywhere. No raw Promise chains, no callbacks unless forced by a library.
- Never block the event loop with sync I/O in production.
- Validate all env vars at startup with a schema (zod/envalid). Fail fast if required config missing.
- No `process.env.FOO` in business logic — use a typed config object from `core/config/`.

## Architecture

- **Controller:** HTTP only — parse, validate, call service, format response. No business logic.
- **Service:** Business logic only. No HTTP, no direct DB. Depends on repository interfaces.
- **Repository:** Data access only. Returns domain objects. No business logic.
- Services depend on repository interfaces, not implementations (DI).

## Error handling

- Typed error classes in `core/errors/` (`NotFoundError`, `ValidationError`, etc.).
- Controllers map domain errors to HTTP status codes. Services/repositories never import HTTP types.
- Centralized error-handling middleware. Never throw plain strings. Never swallow silently.

## Security

- Validate all input at the controller layer (zod schema).
- Parameterized queries only — no string concatenation in SQL.
- Security headers (Helmet). Rate-limit public endpoints. Never log secrets/PII.

## Testing

- Unit test services (mock repositories). Integration test controllers with supertest.
- Test inputs → outputs. Do not test implementation details.
