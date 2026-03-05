# JavaScript Rules

## Structure

- Feature-first: `src/features/<feature>/`, `src/core/`. `index.js` as public barrel.
- No circular imports. No reaching inside a module past its `index.js`.

## Code style

- Prettier + ESLint (`eslint:recommended`). ES module syntax only (`import`/`export`). No `require()`.
- `const` over `let`, never `var`. Named exports preferred.
- **JSDoc types required** on all exported functions and module-level variables.
- No `eslint-disable` without a documented reason.

## Patterns

- **Errors:** Custom classes extending `Error`. Never throw strings. Never swallow silently.
- **Async:** `async`/`await` everywhere. No raw callbacks unless forced by a library.
- **No globals:** No global mutable state. Config passed explicitly.

## Testing

- Jest or Vitest. `<name>.test.js` co-located. Test public API only. Mock at I/O boundaries.
