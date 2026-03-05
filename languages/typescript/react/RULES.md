# TypeScript / React Rules

Extends TypeScript general rules. React-specific rules take precedence.

## Structure

- `src/features/<feature>/components/` and `hooks/` per feature. `src/components/` for shared UI.
- Component files: PascalCase (`UserCard.tsx`). Hook files: camelCase with `use` prefix.

## Components

- Function components only. No class components.
- Props interface (`<Name>Props`) defined directly above component in same file.
- Explicit return type: `function Foo(props: FooProps): JSX.Element`.
- One component per file. Keep components presentational; business logic goes in hooks.
- Lift state only as high as needed. No prop drilling beyond two levels (use context/hook).

## Hooks

- One hook per file. Always `use` prefix. Never call hooks conditionally.
- `useCallback`/`useMemo` only with a measured performance reason — not preemptively.
- Custom hooks encapsulate one concern.

## State

- Local: `useState`. Derived: compute in render, don't store.
- Server state: React Query / SWR. Global UI state: Zustand or context.

## Styling

- One approach per project (CSS Modules, Tailwind, or styled-components). Do not mix.
- No inline styles except for truly dynamic values.

## Testing

- Vitest + React Testing Library. Test behaviour, not implementation.
- Query by role/label. No complex snapshot tests. Hooks: `renderHook`. E2E: Playwright.

