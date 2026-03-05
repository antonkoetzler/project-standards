# Python Rules

## Structure

- Feature-first: `src/<package>/features/<feature>/`. `__init__.py` exports public API only.
- No star imports. One class per file where practical.

## Code style

- Black (line length 88) + Ruff. No exceptions.
- **Type hints required** on all function signatures. No bare `Any` without justification.
- Python 3.10+: `X | Y` union syntax, `str | None` over `Optional[str]`.
- `if __name__ == "__main__":` guard in all runnable scripts.

## Patterns

- **Data:** `@dataclass` for plain data; Pydantic `BaseModel` for validated/serialized data. No raw dicts across boundaries.
- **Paths:** `pathlib.Path` always. No `os.path`. Open files with `with open(path) as f:`.
- **Errors:** Custom exception classes in `core/errors.py`. Catch specific exceptions. Never bare `except:`.
- **Config:** `pydantic-settings` or validated dataclass. No `os.environ.get()` in business logic. Fail fast at startup.
- **DI:** Pass dependencies explicitly. No hard-to-mock module-level singletons.

## Testing

- pytest + pytest-mock. Inject dependencies for easy mocking. No `sys.path` hacks.
