# Project Standards

## Architecture

- Thin controllers delegate to service classes for business logic
- Form Request classes for all validation — no inline validation in controllers
- API-only — no Blade, no views, no server-side HTML

## Routes

All routes in `routes/api.php` under a `v1` prefix group.

### Naming Convention (JSON:API)
- Plural, kebab-case resource names: `/api/v1/user-profiles`
- Nested: `/api/v1/users/{user}/saved-searches`
- Relationship endpoints: `/api/v1/posts/{post}/relationships/tags`
- Route names: dot notation (`v1.users.index`, `v1.blog-posts.store`)

## Controllers

- Organized under `App\Http\Controllers\Api\V1\`
- Only standard RESTful methods: `index`, `store`, `show`, `update`, `destroy`
- Single-action controllers with `__invoke()` for one-off actions

## Service Classes

- Constructor dependency injection
- Accept validated data as typed arrays or individual parameters — never Request objects
- Return Eloquent models/collections directly
- Throw custom exceptions for errors (see `security.md`)

## Directory Structure

```
app/
├── Enums/
├── Http/
│   ├── Controllers/Api/V1/
│   ├── Middleware/
│   └── Requests/
├── Interfaces/
├── Models/
├── Services/
└── Traits/
```

Nest by domain as the project grows (`Services/Auth/`, `Services/Payment/`).

## Database

- Never run `migrate:fresh`, `migrate:reset`, `db:wipe`, or any destructive command
- Always create new migration files — never modify a migration that has been run
- Descriptive migration names: `create_users_table`, `add_status_to_orders_table`
- Create a factory for every model with states for common variations
- Seeders should be idempotent
- Wrap multi-operation requests in `DB::transaction()`

## API Response Classes

- `JsonApiFormRequest` base class: maps rules to `data.attributes.*`, provides `validatedAttributes()` and `validatedRelationships()` helpers
- `JsonApiResource` base class: wraps models with `type`, `id`, `attributes`, `relationships`
- `JsonApiCollection`: handles collections with cursor pagination metadata
- `JsonApiErrorResponse`: standardized error responses
- Content-type middleware rejects requests without `application/vnd.api+json`

### Included Resources (Sideloading)

Use the JSON:API `included` array for eager-loaded relationships. Support `?include=author,tags` query parameter. Only include requested resources.

## Filtering and Sorting

Implement via Eloquent query scopes (`scopeFilter`, `scopeSort`). Use allowlists — reject unknown fields. Support exact match by default; add operators only when a spec requires it.

## Code Style

- PSR-12, 4-space indentation, 120-char soft line limit
- Single quotes unless interpolation needed
- Trailing commas on multi-line structures
- Explicit return types and parameter types on all methods

### Import Ordering (3 groups, alphabetical, separated by blank lines)
1. PHP/global classes
2. Laravel framework classes (`Illuminate\...`)
3. Application classes (`App\...`)

### Enums
Use PHP 8.1+ backed enums. Error codes defined as `App\Enums\ErrorCode`.

## Naming Conventions

| Entity | Convention | Example |
|--------|-----------|---------|
| Models | Singular PascalCase | `User`, `OrderItem` |
| Tables | Plural snake_case | `users`, `order_items` |
| Pivot tables | Alphabetical singular snake_case | `order_product` |
| Controllers | Singular PascalCase + suffix | `UserController` |
| Form Requests | Descriptive PascalCase | `StoreUserRequest` |
| Services | Singular PascalCase + suffix | `UserService` |
| JSON:API `type` | Plural lowercase kebab-case | `users`, `blog-posts` |

## Mass Assignment

Use `$fillable` on all models. Never use `$guarded`.
