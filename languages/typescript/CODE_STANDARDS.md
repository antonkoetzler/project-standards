# TypeScript Code Standards

Documentation is for engineers and AI: key points, behavior, intent; avoid long prose.

## Project structure

Feature-first layout:

```
src/
  core/          # Shared utilities, types, DI config, error classes
  features/
    <feature>/
      index.ts         # Public API (barrel export)
      <feature>.service.ts
      <feature>.types.ts
      <feature>.test.ts
  main.ts
```

- One module per folder. `index.ts` is the public barrel — do not reach inside a module.
- No circular imports. Dependency direction: `features` → `core`. `core` never imports from `features`.

## Naming conventions

- **Files:** kebab-case (`user-service.ts`, `api-client.ts`).
- **Classes/Interfaces/Types/Enums:** PascalCase.
- **Functions/variables:** camelCase.
- **Constants:** SCREAMING_SNAKE_CASE for module-level constants; camelCase for local.
- **Interfaces:** no `I` prefix (`UserRepository`, not `IUserRepository`).
- **Generic params:** single letter (`T`, `K`, `V`) or descriptive (`TItem`, `TKey`).

## Code style

- **Formatter:** Prettier (`.prettierrc` in repo root). No exceptions.
- **Linter:** ESLint with `typescript-eslint` strict preset.
- `strict: true` in `tsconfig.json`. No `any`. Use `unknown` + type guards.
- Explicit return types on all exported functions and class methods.
- Prefer `const` over `let`. Never `var`.
- Prefer named exports over default exports (aids refactoring and search).
- No `// @ts-ignore` or `// @ts-expect-error` without a documented reason.

## Key patterns

### Error handling
- Typed errors: define custom error classes extending `Error`.
- Never throw plain strings. Never swallow errors silently.
- `async` functions return `Promise<T>` — always `await` or propagate.

### Interfaces and types
- `interface` for object shapes that may be implemented or extended.
- `type` for unions, intersections, mapped types, and aliases.
- Prefer `readonly` on interface properties that should not be mutated.

### Dependency injection
- Use a DI container (e.g. `tsyringe`, `inversify`) or constructor injection manually.
- Never `new` a dependency inside a class. Pass through constructor.
- Register dependencies at the composition root (`main.ts` or an `app.module.ts`).

### Modules
- Use ES module syntax (`import`/`export`). No `require()`.
- Each module owns its types — do not leak internal types through barrel exports.

## Testing

- Framework: Jest or Vitest. Co-locate tests: `<name>.test.ts` next to the module.
- Unit test public API, not internals. Mock at the boundary (I/O, network, DB).
- No test accesses private properties via `(obj as any)`.
- Coverage: 80% minimum; 100% for core business logic.
