# JavaScript Code Standards

Documentation is for engineers and AI: key points, behavior, intent; avoid long prose.

Same principles as TypeScript general standards. JS-specific differences below.

## Project structure

```
src/
  core/          # Shared utilities, error classes, config
  features/
    <feature>/
      index.js
      <feature>.service.js
      <feature>.types.js   # JSDoc type definitions
      <feature>.test.js
  main.js
```

## Naming conventions

- **Files:** kebab-case. **Classes:** PascalCase. **Functions/vars:** camelCase.
- **Constants:** SCREAMING_SNAKE_CASE at module level; camelCase locally.
- No `I` prefix on JSDoc `@typedef` interfaces.

## Code style

- **Formatter:** Prettier. **Linter:** ESLint with `eslint:recommended` + custom config.
- ES2020+ syntax. ES module syntax (`import`/`export`). No `require()`.
- `const` over `let`. Never `var`.
- **JSDoc types required** on all exported functions and module-level variables.
- Named exports preferred over default exports.
- No `// eslint-disable` without a documented reason.

### JSDoc example
```js
/**
 * Fetches a user by ID.
 * @param {string} id
 * @returns {Promise<User>}
 */
export async function getUser(id) { ... }

/**
 * @typedef {Object} User
 * @property {string} id
 * @property {string} name
 */
```

## Key patterns

### Error handling
- Typed errors: custom classes extending `Error` with a `name` property.
- Never throw plain strings. Never swallow errors silently.
- `async`/`await` everywhere. No raw callbacks unless forced by a library.

### Modules
- One module per file. `index.js` as public barrel.
- No circular imports. No reaching inside a module past its `index.js`.

### No globals
- No global mutable state. No `window.foo = ...` in library code.
- Configuration passed explicitly, not via globals or ambient injection.

## Testing

- Framework: Jest or Vitest. `<name>.test.js` co-located.
- Test public API, not internals. Mock at I/O boundaries.
- JSDoc types must be consistent with test inputs.
