# Rust Rules

## Structure

- `src/main.rs` minimal (calls `lib::run()`). `src/lib.rs` is the library root.
- `src/core/error.rs` for project-wide `Error` type (thiserror). One `mod.rs` per module.
- Workspace layout for multi-crate projects.

## Code style

- `rustfmt` on save (`cargo fmt`). `clippy` with `-D warnings` — all warnings are errors in CI.
- Edition: `rust 2021`.

## Patterns

- **Errors:** `thiserror` for typed error enums. Return `Result<T, Error>` from all fallible functions. No `.unwrap()` in production. Use `?` to propagate. `.expect("reason")` only in tests or truly unrecoverable states. No `panic!` in library crates.
- **Ownership:** Prefer references over cloning. `Arc<T>` for shared cross-thread ownership. `Mutex<T>` / `RwLock<T>` for interior mutability.
- **Traits:** Prefer static dispatch (`impl Trait` bounds). `dyn Trait` only when dynamic dispatch is intentional.
- **Async:** `tokio` runtime only. Never block inside async (`thread::sleep`, blocking I/O). Always `.await` or abort task handles.
- **RAII:** Resources tied to lifetimes. `Drop` for deterministic release. No manual cleanup outside `Drop`.

## Testing

- Unit tests in `#[cfg(test)]` at bottom of file. Integration tests in `tests/`.
- Trait-based test doubles or `mockall`. Return `Result` from tests instead of `should_panic`.
