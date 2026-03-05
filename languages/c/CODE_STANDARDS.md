# C Code Standards

Documentation is for engineers and AI: key points, behavior, intent; avoid long prose.

## Project structure

```
src/
  main.c
  core/
    error.h / error.c      # Error codes and error handling utilities
    memory.h / memory.c    # Allocation wrappers (never call malloc directly)
  features/
    <feature>/
      <feature>.h          # Public interface — what callers see
      <feature>.c          # Implementation — never include directly
include/
  <project>/               # Public headers installable by the build system
tests/
  test_<feature>.c
CMakeLists.txt
```

- Headers expose only the public API. Implementation details stay in `.c` files.
- Use `#pragma once` (or traditional header guards) in every header.
- Include only what you use. No wildcard includes.

## Naming conventions

- **Files:** snake_case (`user_service.c`, `user_service.h`).
- **Functions:** snake_case, prefixed by module (`user_create`, `user_destroy`).
- **Types (typedef):** PascalCase with `_t` suffix (`UserContext_t`) or just PascalCase (`UserContext`). Be consistent per project.
- **Constants/macros:** SCREAMING_SNAKE_CASE. Macros: prefer `static const` or `enum` over `#define` for typed constants.
- **Structs:** PascalCase (`UserContext`); private fields with no special prefix.

## Code style

- **Formatter:** `clang-format` (`.clang-format` in repo root, Google or project style).
- **Linter:** `clang-tidy` with a project `.clang-tidy` config. Address sanitizer in debug builds.
- C11 minimum (`-std=c11`). Enable warnings: `-Wall -Wextra -Wpedantic -Werror`.
- No implicit function declarations. Include the correct header for every function used.
- All variables declared at the top of their scope (C89-compatible habit avoids surprises).

## Key patterns

### Memory management
- Every `malloc`/`calloc` return value is checked. Never assume allocation succeeds.
- Wrap allocation in a project utility (`mem_alloc`, `mem_free`) that handles OOM consistently.
- Every allocated resource has a corresponding free function called at the right time.
- No memory leaks: use Valgrind or AddressSanitizer in CI (run tests with ASan).
- Ownership must be documented in the header: who owns a pointer, who frees it.

### Error handling
- Functions return an error code (`int` or a project `ErrorCode_t` enum). Never ignore return values.
- Error strings via a `error_to_string(ErrorCode_t)` utility, not raw integers in logs.
- Do not use `errno` for application-level errors — define your own error codes.
- No `goto` for general control flow; acceptable for cleanup patterns (`goto cleanup`).

### No global state
- No global mutable variables except for module initialization state (and even that is minimized).
- Pass context structs through function parameters.
- Thread-safe by design: no hidden shared state.

### Strings
- Use `strncpy`/`strncat` with explicit bounds. Never `strcpy`/`strcat`.
- Prefer `snprintf` over `sprintf`. Always check length.
- All strings are explicitly null-terminated; document buffer sizes.

## Testing

- Framework: Unity, Criterion, or CMocka. Test each module in isolation.
- Tests compile with `-fsanitize=address,undefined`. All tests must pass clean under sanitizers.
- Mock external I/O and system calls by linking test stubs.
