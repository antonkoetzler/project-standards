# C++ Code Standards

Documentation is for engineers and AI: key points, behavior, intent; avoid long prose.

## Project structure

```
src/
  main.cpp
  core/
    Error.hpp / Error.cpp
    Memory.hpp             # RAII wrappers, allocator utilities
  features/
    <feature>/
      <Feature>.hpp        # Public interface
      <Feature>.cpp        # Implementation
      <Feature>Impl.hpp    # Private implementation details (optional)
include/
  <project>/              # Public headers for library consumers
tests/
  <Feature>Test.cpp
CMakeLists.txt
```

- Headers expose only the public API. Use `#pragma once`.
- Prefer `.hpp`/`.cpp` extensions. Keep implementation out of headers unless templated.
- Template implementations in `.tpp` files included at the bottom of the corresponding `.hpp`.

## Naming conventions

- **Files:** PascalCase for class files (`UserService.hpp`), snake_case for utilities.
- **Classes/Structs/Enums:** PascalCase.
- **Functions/methods:** camelCase. **Member variables:** `m_` prefix (`m_userId`) or trailing underscore — consistent per project.
- **Constants:** SCREAMING_SNAKE_CASE. **Template params:** single uppercase (`T`, `U`, `Key`, `Value`).
- **Namespaces:** lowercase, snake_case. Mirror directory structure.

## Code style

- **Formatter:** `clang-format` (`.clang-format` in root, Google or project style).
- **Linter:** `clang-tidy` with `.clang-tidy` config. Enable sanitizers in debug builds.
- C++17 minimum; C++20 preferred (concepts, ranges, `std::span`, `std::format`).
- Enable: `-Wall -Wextra -Wpedantic -Werror`. Address all warnings.
- `auto` for long type names when the type is obvious from context. Never `auto` when it hides important type information.

## Key patterns

### RAII
- Every resource is managed by an RAII object. No manual resource acquisition/release outside of constructors/destructors.
- Destructors must not throw. Use `noexcept` on destructors.
- Tie file handles, locks, connections, and memory to object lifetimes.

### Smart pointers
- `std::unique_ptr<T>` for exclusive ownership (default for heap allocation).
- `std::shared_ptr<T>` only when shared ownership is genuinely required.
- `std::weak_ptr<T>` to break shared ownership cycles.
- No raw `new`/`delete`. No raw owning pointers. Use `std::make_unique` and `std::make_shared`.
- Raw (non-owning) pointers and references are fine for observation.

### Error handling
- Use exceptions for exceptional conditions. Define a custom exception hierarchy.
- No error codes mixed with exceptions — pick one style per module boundary.
- `[[nodiscard]]` on functions whose return value must be checked.
- RAII ensures cleanup even when exceptions propagate.

### Move semantics
- Implement move constructor and move assignment for resource-owning types (Rule of Five or Rule of Zero).
- Pass by value when taking ownership. Pass by `const&` for read-only access. Pass by `&&` only in perfect-forwarding templates.
- Mark move-only types explicitly: delete copy constructor and copy assignment.

### Const correctness
- All member functions that don't modify state are `const`.
- Prefer `const` local variables. Prefer `const&` parameters over non-const.
- `constexpr` for compile-time constants and functions.

### Concurrency
- `std::thread`, `std::mutex`, `std::atomic`. No platform-specific threading primitives.
- Protect shared state with `std::mutex` or `std::atomic`. Document thread ownership.
- Prefer `std::async` or a thread pool over raw `std::thread` for task-based work.

## Testing

- Framework: Google Test (GTest) or Catch2. Tests in `tests/` mirroring `src/`.
- Use `EXPECT_*` over `ASSERT_*` unless the test cannot proceed on failure.
- Compile tests with `-fsanitize=address,undefined`. All tests must pass clean under sanitizers.
- Mock with Google Mock or manual test doubles inheriting from interfaces.
