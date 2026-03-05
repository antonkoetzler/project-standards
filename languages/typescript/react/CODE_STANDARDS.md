# TypeScript / React Code Standards

Documentation is for engineers and AI: key points, behavior, intent; avoid long prose.

Extends the TypeScript general standards. React-specific rules below take precedence.

## Project structure

```
src/
  core/           # Shared hooks, context, utilities, types
  features/
    <feature>/
      index.ts          # Public barrel
      components/       # Feature-scoped components
      hooks/            # Feature-scoped hooks
      <feature>.types.ts
  components/     # Truly shared/generic UI components
  pages/          # Route-level components (or app/router config)
  main.tsx
```

## Naming conventions

- **Component files:** PascalCase (`UserCard.tsx`).
- **Hook files:** camelCase, `use` prefix (`useUserData.ts`).
- **Component functions:** PascalCase. **Props interfaces:** `<Name>Props`.
- Non-component files: kebab-case (same as TypeScript general).

## Code style

- **Formatter:** Prettier. **Linter:** ESLint + `eslint-plugin-react-hooks`.
- Function components only. No class components.
- Props interface defined in the same file, directly above the component.
- Explicit return type on components: `function Foo(props: FooProps): JSX.Element`.
- One component per file. Private sub-components may live in the same file only if they are tiny and never reused.

## Key patterns

### Components
- Keep components pure and presentational where possible. Business logic in hooks.
- Lift state only as high as needed. Prefer local state; use context for truly shared state.
- Avoid prop drilling beyond two levels — introduce context or a hook.

### Hooks
- One hook per file. Hooks start with `use`. Never call hooks conditionally.
- `useCallback` and `useMemo` only when there is a measured performance reason — not by default.
- Custom hooks encapsulate one concern. Extract from components when logic is reused or complex.

### State management
- Local state: `useState`. Derived state: compute in render, do not store.
- Server state: React Query / SWR. Global UI state: Zustand or React context.
- No direct Redux unless already in use. Prefer lighter solutions.

### Styling
- One styling approach per project (CSS Modules, Tailwind, or styled-components). Do not mix.
- No inline styles except for truly dynamic values that can't be expressed as classes.

## Testing

- Framework: Vitest + React Testing Library.
- Test user behaviour, not implementation. Query by role/label, not by class or test ID.
- No snapshot tests for complex components — they hide intent and break easily.
- Unit test hooks with `renderHook`. Integration test pages/features end-to-end with Playwright.
