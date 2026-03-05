# C++ Rules

## Structure

- `src/<Feature>/<Feature>.hpp` (public API) + `<Feature>.cpp` (implementation). `#pragma once` in every header.
- Template implementations in `.tpp` included at bottom of `.hpp`.
- Namespaces: lowercase, mirror directory structure.

## Code style

- `clang-format` (`.clang-format` in root). `clang-tidy` with `.clang-tidy` config.
- C++17 minimum; C++20 preferred. `-Wall -Wextra -Wpedantic -Werror`.

## Patterns

- **RAII:** Every resource tied to object lifetime. Destructors `noexcept`. No manual resource cleanup outside destructors.
- **Smart pointers:** `unique_ptr` by default. `shared_ptr` only for shared ownership. `make_unique`/`make_shared` always. No raw `new`/`delete`.
- **Errors:** Exceptions for exceptional conditions. Custom exception hierarchy. `[[nodiscard]]` on must-check returns. RAII ensures cleanup on exception.
- **Move semantics:** Rule of Five or Rule of Zero. Pass by value for ownership, `const&` for read. Mark move-only types explicitly.
- **Const correctness:** All non-mutating methods `const`. `constexpr` for compile-time constants.
- **Concurrency:** `std::mutex`, `std::atomic`. No platform primitives. Protect all shared state.

## Testing

- GTest or Catch2. `EXPECT_*` over `ASSERT_*`. ASan + UBSan. Google Mock or test doubles from interfaces.
