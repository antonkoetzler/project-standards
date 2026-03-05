# Flutter Rules

Extends Dart rules. Also select "Dart (general)" for complete Dart language rules.

## Structure

- Feature-first under `lib/`. Single-file modules in their own folder — no exceptions.
- `lib/core/` — routing, DI, l10n, shared utilities. One module per folder.
- `lib/features/<feature>/shell/` and `features/<feature>/screen/` for shells and screens.
- Private widgets: `_widgets/` folder in same scope, underscore-prefixed files (`_widgets/_shell_sidebar.dart`), connected via `part`/`part of`.

## Routing

- Path constants in `lib/core/routing/app_routes.dart` (`AppRoutes.home`). No raw strings anywhere.
- Router built in one place (`app_router.dart`) using only `AppRoutes.*` constants.

## Code style

- Class member order: (1) Static: fields→functions→getters→setters→operators. (2) Constructors. (3) Fields. (4) Functions. (5) Getters/Setters/Operators. Within each: overrides→public→private.
- Omit parameter types when inferred: `build(context)` not `build(BuildContext context)`.
- `final class` for widgets/classes not designed for extension. Ternary for two-way branches — no `if`/`return` binary choices.
- Never use `as`/`is` keywords — use OOP inheritance and polymorphism instead. `sealed class` for widget variants.
- `build()` minimal: no logic, no long blocks. Extract to named methods. One abstraction level per method.
- Data-driven over repeated widget blocks. Extract patterns into reusable widgets/extensions in `core/`.
- `const` constructors everywhere possible. No magic numbers. No `print` in production.
- `MediaQuery.sizeOf(context)` over `.of(context).size` for breakpoint checks.

## Design system

- Custom `ThemeExtension` classes for design system values. Semantic color tokens, not raw hex.
- Builder functions for theme construction. No scattered theme logic in widgets.

## State management

- Provider for reactive state. Constructor injection preferred.
- DI: injectable + get_it, kiwi, or manual — pick one per project.

## Localization

- All user-facing strings via Flutter l10n. No hardcoded display text.

## Conventions

- No `.vscode/tasks.json`, `.vscode/launch.json`, `.idea/` committed.

