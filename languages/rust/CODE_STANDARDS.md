# Rust Code Standards

Documentation is for engineers and AI: key points, behavior, intent; avoid long prose.

## Project structure

```
src/
  main.rs          # Binary entry point — minimal, just calls lib::run()
  lib.rs           # Library root — re-exports public API
  core/
    mod.rs
    error.rs       # Project-wide Error type (thiserror)
    config.rs
  features/
    <feature>/
      mod.rs
      service.rs
      repository.rs
      model.rs
Cargo.toml
```

- Workspace layout for multi-crate projects: `Cargo.toml` at root with `[workspace]`.
- Keep `main.rs` thin. Business logic lives in `lib.rs` and modules.
- One `mod.rs` per module folder. Expose only what is needed via `pub`.

## Naming conventions

- **Files/modules:** snake_case. **Types/Traits/Enums:** PascalCase. **Functions/vars:** snake_case.
- **Constants:** SCREAMING_SNAKE_CASE. **Lifetimes:** short, `'a`, `'b`, or descriptive `'conn`.
- **Traits:** describe behavior as adjective or noun (`Display`, `Iterator`, `Serializable`).
- **Error types:** `<Feature>Error` (e.g. `AuthError`, `StorageError`).

## Code style

- **Formatter:** `rustfmt` (run on save, or `cargo fmt`). Configured via `rustfmt.toml`.
- **Linter:** `clippy` (`cargo clippy -- -D warnings`). All warnings are errors in CI.
- Edition: `rust 2021` in `Cargo.toml`.

## Key patterns

### Error handling
- Use `thiserror` to define typed error enums. Every module that can fail has its own `Error` type.
- Return `Result<T, Error>` from all fallible functions.
- No `.unwrap()` in production code. Use `?` to propagate. Use `.expect("descriptive reason")` only in tests or when a panic is truly unrecoverable.
- Avoid `panic!` in library code. Reserve for truly unreachable states.
- Use `anyhow` only in application code (binaries), not in library crates.

### Ownership and borrowing
- Prefer references over cloning. Clone only when ownership is genuinely needed.
- Return owned types from constructors. Accept references in functions when caller keeps ownership.
- `Arc<T>` for shared ownership across threads. `Rc<T>` only in single-threaded code.
- `Mutex<T>` / `RwLock<T>` for interior mutability across threads.

### Traits and generics
- Prefer trait bounds in `impl` blocks over `dyn Trait` unless dynamic dispatch is intentional.
- `dyn Trait` for heterogeneous collections or when monomorphization cost is unacceptable.
- Implement standard traits where appropriate: `Debug`, `Display`, `Clone`, `PartialEq`, `Hash`.

### Async
- Use `tokio` as the async runtime. No mixing runtimes.
- All async functions return `impl Future` or are `async fn`. Never block inside an async context (`thread::sleep`, blocking I/O).
- Use `tokio::spawn` for concurrent tasks. Join handles must be awaited or aborted explicitly.

### Resource management (RAII)
- Resources are tied to lifetimes. Use `Drop` to release resources deterministically.
- No manual resource cleanup outside `Drop` implementations.
- Prefer `BufReader`/`BufWriter` for file I/O.

## Testing

- Unit tests in `#[cfg(test)]` module at the bottom of each file.
- Integration tests in `tests/` directory (separate from `src/`).
- Use `#[should_panic(expected = "...")]` sparingly — prefer `Result`-returning tests.
- Mock with `mockall` or trait-based test doubles.
- `cargo test -- --nocapture` for debugging test output.
