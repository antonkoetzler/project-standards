# Python Code Standards

Documentation is for engineers and AI: key points, behavior, intent; avoid long prose.

## Project structure

```
src/
  <package>/
    __init__.py
    core/
      config.py        # Settings via pydantic-settings or dataclass
      errors.py        # Custom exception classes
    features/
      <feature>/
        __init__.py
        service.py
        repository.py
        models.py      # Dataclasses or Pydantic models
        tests/
          test_service.py
main.py
pyproject.toml
```

- One class per file where practical. `__init__.py` as public API — only export what is public.
- No star imports (`from module import *`).

## Naming conventions

- **Files/modules:** snake_case. **Classes:** PascalCase. **Functions/vars:** snake_case.
- **Constants:** SCREAMING_SNAKE_CASE at module level.
- **Private:** single underscore prefix (`_internal`). Double underscore only for name mangling (rare).
- **Type params:** `T`, `K`, `V` or descriptive with `TypeVar`.

## Code style

- **Formatter:** Black (line length 88). No exceptions.
- **Linter:** Ruff (covers isort, pyflakes, pycodestyle, and more).
- **Type hints required** on all function signatures (PEP 484). No bare `Any` without justification.
- Python 3.10+ syntax: `match`, `X | Y` union syntax, `str | None` instead of `Optional[str]`.
- `if __name__ == "__main__":` guard in all runnable scripts.

## Key patterns

### Data classes
- Use `@dataclass` (or `@dataclass(frozen=True)` for immutable) for plain data.
- Use Pydantic `BaseModel` for data that needs validation or JSON serialization.
- Never use raw dicts for structured data that crosses function boundaries.

### Paths and I/O
- `pathlib.Path` over `os.path`. Always. No `os.path.join`, `os.getcwd()`, etc.
- Open files with `with open(path) as f:` — never leave file handles open.
- Use `Path(__file__).parent` to reference files relative to the current module.

### Error handling
- Define custom exception classes in `core/errors.py`. Inherit from a base project exception.
- Catch specific exceptions, not bare `except:` or `except Exception:` without re-raising.
- Never use exceptions for flow control. Never swallow exceptions silently.

### Configuration
- All config from environment via `pydantic-settings` or a validated dataclass.
- No `os.environ.get("FOO")` scattered in business logic. Use a typed config object.
- Fail fast: validate config at startup.

### Dependency injection
- Prefer passing dependencies explicitly as constructor or function arguments.
- Use a DI framework (e.g. `dependency-injector`) for large projects.
- No module-level singletons that are hard to mock in tests.

## Testing

- Framework: pytest. Tests in `tests/` mirroring `src/` structure, or co-located in `tests/` subfolders.
- Use `pytest-mock` or `unittest.mock` for mocking. Inject dependencies to make mocking easy.
- No `sys.path` manipulation in tests — install the package in editable mode (`pip install -e .`).
- Type-annotate test helpers but not test functions themselves.
