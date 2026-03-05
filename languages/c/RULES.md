# C Rules

## Structure

- `src/<feature>/<feature>.h` (public API) + `<feature>.c` (implementation). Never include `.c` directly.
- `#pragma once` in every header. Include only what you use.
- `src/core/memory.h` wraps allocation. Never call `malloc` directly.

## Code style

- `clang-format` (`.clang-format` in root). `clang-tidy` with project config.
- C11 minimum. `-Wall -Wextra -Wpedantic -Werror`. No implicit function declarations.

## Patterns

- **Memory:** Check every `malloc`/`calloc` return. Wrap in project allocator. Every allocation has a paired free. Document ownership in headers. ASan + Valgrind in CI.
- **Errors:** Return error code enum from every fallible function. Never ignore return values. `error_to_string()` utility. No `errno` for app-level errors. `goto cleanup` pattern for multi-resource cleanup.
- **No global state:** Pass context structs through parameters. No hidden shared mutable state.
- **Strings:** `strncpy`/`strncat` with bounds. `snprintf` over `sprintf`. Explicit null termination.

## Testing

- Unity/Criterion/CMocka. Compile with `-fsanitize=address,undefined`. All tests pass clean under sanitizers.
