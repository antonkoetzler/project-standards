# TypeScript Rules

## Structure

- Feature-first: `src/features/<feature>/`, `src/core/`. One module per folder, `index.ts` as public barrel.
- No circular imports. `features` → `core` only. `core` never imports from `features`.

## Code style

- Prettier (`.prettierrc`) + ESLint (`typescript-eslint` strict). No exceptions.
- `strict: true` in tsconfig. No `any` — use `unknown` + type guards.
- Explicit return types on all exported functions and class methods.
- `const` over `let`, never `var`. Named exports preferred over default exports.
- No `@ts-ignore` / `@ts-expect-error` without documented reason.

## Patterns

- **Errors:** Typed custom error classes. Never throw strings. Never swallow silently.
- **Interfaces:** for object shapes. **Types:** for unions, intersections, aliases. `readonly` on immutable props.
- **DI:** Constructor injection. Never `new` a dependency inside a class. Register at composition root.
- **Modules:** ES module syntax only (`import`/`export`). No `require()`.

## Testing

- Jest or Vitest. `<name>.test.ts` co-located. Test public API only.
- Mock at I/O boundaries. No access to private via `as any`.
