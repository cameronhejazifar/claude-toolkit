# Testing Standards

Use Pest for all tests.

## Structure

```
tests/
├── Unit/
│   ├── Services/
│   └── Models/
├── Feature/
│   └── Api/V1/
└── Pest.php
```

- `Unit/` — Isolated tests for services, helpers, models
- `Feature/` — Full HTTP lifecycle tests by API version and resource
- One test file per endpoint group (`tests/Feature/Api/V1/Users/CreateUserTest.php`)

## Conventions

- `it()` syntax: `it('can create a user')`
- `describe()` for grouping related tests, `beforeEach()` for shared setup
- `dataset()` for parameterized input variations
- `expect()` for all assertions — not `$this->assert*()`
- `LazilyRefreshDatabase` on all Feature tests
- `actingAs($user)` for authenticated requests

## Factories

- Factory for every model with states for common variations (`unverified`, `admin`)
- Use `recycle()` to reuse related models instead of creating duplicates

## Required Coverage

- Unit tests for all service methods, model scopes, accessors, mutators
- Feature tests for every API route across all auth states (unauthenticated, wrong user, authorized)
- Assert full JSON:API response structure, not just status codes
- Validation errors: assert `errors[0].code`, `errors[0].source.pointer`, and `errors[0].detail`
- Pagination: assert `meta.cursor` structure, test cursor navigation, test edge cases (empty, single page)

## Mocking

- Mock external services only: `Mail::fake()`, `Queue::fake()`, `Http::fake()`
- Never mock the database — use `LazilyRefreshDatabase`
- Never mock service classes in Feature tests — exercise the full stack

## Rules

- Never comment out or remove a test
- Tests are written before implementation (TDD)
