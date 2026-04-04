# Foundation Spec

This spec defines the infrastructure that must be built immediately after the manual project setup (see `docs/setup/`). It establishes the plumbing that all future feature specs depend on. No feature development should begin until this spec is fully implemented.

## Prerequisites

Before starting, the manual setup process must be complete:
- `api/` — Laravel 13 project with Sail, MySQL, Redis, Meilisearch, Mailpit. Sanctum installed. Web routes and Blade removed.
- `web/` — Vue 3 project with TypeScript, Pinia, Vue Router, Vitest. Docker Compose configured on port 50301. Environment variables set.

---

## API (`api/`)

### 1. ErrorCode Enum

Create `App\Enums\ErrorCode` as a string-backed enum with all error codes from the root CLAUDE.md:

```
AUTH_REQUIRED, AUTH_INVALID, AUTH_REVOKED, EMAIL_UNVERIFIED,
FORBIDDEN, OWNERSHIP_REQUIRED, VALIDATION_FAILED, INVALID_FORMAT,
NOT_FOUND, ALREADY_EXISTS, GONE, RATE_LIMITED, SERVER_ERROR,
SERVICE_UNAVAILABLE, MAINTENANCE, ACTION_NOT_ALLOWED, STATE_CONFLICT
```

### 2. Base Exception Class

Create `App\Exceptions\ApiException`:
- Properties: `ErrorCode $code`, `int $status`, `string $message`
- Constructor accepts all three, with sensible defaults from the enum

Create domain exceptions extending `ApiException`, each with a fixed code and status:

| Exception | Code | Status |
|-----------|------|--------|
| `EmailUnverifiedException` | `EMAIL_UNVERIFIED` | 403 |
| `OwnershipRequiredException` | `OWNERSHIP_REQUIRED` | 403 |
| `AlreadyExistsException` | `ALREADY_EXISTS` | 409 |
| `GoneException` | `GONE` | 410 |
| `ActionNotAllowedException` | `ACTION_NOT_ALLOWED` | 422 |
| `StateConflictException` | `STATE_CONFLICT` | 409 |
| `ServiceUnavailableException` | `SERVICE_UNAVAILABLE` | 503 |

### 3. Global Exception Handler

Register in `bootstrap/app.php`. Catches all exceptions and renders JSON:API error responses (`application/vnd.api+json`).

Mapping:
- `ApiException` subclasses → use their code and status
- `AuthenticationException` → `AUTH_REQUIRED`, 401
- `AuthorizationException` → `FORBIDDEN`, 403
- `ModelNotFoundException` → `NOT_FOUND`, 404
- `ValidationException` → `VALIDATION_FAILED`, 422 (transform each error into a separate JSON:API error object with `source.pointer` set to `/data/attributes/{field}`)
- `ThrottleRequestsException` → `RATE_LIMITED`, 429
- All other exceptions → `SERVER_ERROR`, 500

Response shape:
```json
{
  "errors": [{
    "status": "422",
    "code": "VALIDATION_FAILED",
    "title": "Validation Error",
    "detail": "The email field must be a valid email address.",
    "source": { "pointer": "/data/attributes/email" }
  }]
}
```

### 4. JSON:API Content-Type Middleware

Create `App\Http\Middleware\ValidateJsonApiContentType`:
- Reject requests without `Content-Type: application/vnd.api+json` with 415 status and `INVALID_FORMAT` error code
- Exempt `GET` and `DELETE` requests (they may not have a body)

### 5. Rate Limiting

Configure in `AppServiceProvider` or `RouteServiceProvider`:
- 60 requests per minute per authenticated user (or per IP if unauthenticated)

### 6. Middleware Stack

Register middleware on the `v1` API route group in the following order:
1. Rate limiting (`throttle:api`)
2. JSON:API content-type validation
3. Sanctum authentication applied per-route (not globally on the group)

### 7. CORS Configuration

Update `config/cors.php` to read from `CORS_ALLOWED_ORIGINS` env var:
- Allowed methods: `GET, POST, PUT, PATCH, DELETE, OPTIONS`
- Allowed headers: `Content-Type, Authorization, Accept`
- Supports credentials: `false`

### 8. JsonApiFormRequest Base Class

Create `App\Http\Requests\JsonApiFormRequest` extending `FormRequest`:
- Validates `data.type` matches the expected resource type (defined by subclass)
- Maps validation rules defined with simple field names to `data.attributes.*` paths automatically
- Provides `validatedAttributes(): array` — returns flat validated attributes ready for Eloquent
- Provides `validatedRelationships(): array` — resolves `data.relationships` into `['foreign_key' => id]` format

Subclasses define:
- `resourceType(): string` — the expected `data.type` value
- `rules(): array` — simple field-level rules (base class handles nesting)

### 9. JsonApiResource Base Class

Create `App\Http\Resources\JsonApiResource` extending Laravel's `JsonResource`:
- Output shape: `{ "data": { "type": "...", "id": "...", "attributes": {...}, "relationships": {...} } }`
- Subclasses define `resourceType(): string`, `attributes(): array`, `relationships(): array`
- Supports `included` top-level array for sideloaded eager-loaded relationships
- Parse `?include=author,tags` query parameter and pass to Eloquent `with()` for eager loading. Validate requested includes against an allowlist defined on each resource subclass (`$availableIncludes` array). Reject unknown includes.

### 10. JsonApiCollection

Create `App\Http\Resources\JsonApiCollection` extending `ResourceCollection`:
- Wraps a paginated collection using `JsonApiResource` items
- Adds `meta.cursor` with `next`, `prev`, `count`, `per_page` from cursor pagination

### 11. JsonApiErrorResponse

Create `App\Http\Resources\JsonApiErrorResponse`:
- Static helper for building error response arrays matching the JSON:API error format
- Used by the global exception handler

### 12. Route Structure

Set up versioned route group in `routes/api.php`:

```php
Route::prefix('v1')->middleware(['throttle:api', 'json.api'])->group(function () {
    // Public routes here

    Route::middleware('auth:sanctum')->group(function () {
        // Protected routes here
    });
});
```

### 13. Sanctum Configuration

- Ensure Sanctum is configured for personal access token issuance (no SPA/cookie auth)
- No token expiration by default

### 14. Directory Scaffolding

Create empty directories for the expected project structure:

```
app/Enums/
app/Exceptions/
app/Http/Controllers/Api/V1/
app/Http/Middleware/
app/Http/Requests/
app/Http/Resources/
app/Interfaces/
app/Models/
app/Services/
app/Traits/
tests/Unit/Services/
tests/Unit/Models/
tests/Feature/Api/V1/
```

### 15. Filterable and Sortable Traits

Create `App\Traits\Filterable` and `App\Traits\Sortable` traits:
- `scopeFilter(Builder $query, array $filters)` — filters against an allowlist defined on the model (`$filterable` property)
- `scopeSort(Builder $query, string $sort)` — parses JSON:API sort string (`-created_at,name`) against an allowlist defined on the model (`$sortable` property)
- Models opt in by using the traits and defining `$filterable` and `$sortable` arrays

### 16. Tests

Write tests before implementation (TDD). At minimum:
- Unit test for `ErrorCode` enum — all cases exist and have the expected string values
- Feature test for content-type middleware — rejects invalid content type, accepts valid
- Feature test for exception handler — each exception type produces the correct JSON:API error response
- Feature test for rate limiting — returns 429 after exceeding limit
- Unit test for `JsonApiFormRequest` — validates type, maps rules, extracts attributes and relationships
- Unit test for `JsonApiResource` — output matches expected JSON:API structure
- Unit test for `JsonApiCollection` — output includes cursor pagination metadata
- Unit test for `Filterable` and `Sortable` traits — filters/sorts against allowlist, rejects unknown fields

---

## Web (`web/`)

### 1. Install Dependencies

The following packages need to be installed (get approval before running):
- `tailwindcss` + `@tailwindcss/vite` — styling
- `axios` — HTTP client
- `@vue/test-utils` — component test mounting
- `axe-core` + `vitest-axe` — accessibility testing

### 2. Tailwind CSS Setup

Configure Tailwind with `@tailwindcss/vite` plugin in `vite.config.ts`. Create `src/assets/main.css` with `@import "tailwindcss"`. Import in `main.ts`.

### 3. Axios Client

Create `src/api/client.ts`:
- Create an Axios instance with base URL from `import.meta.env.VITE_API_URL`
- Set `Content-Type` and `Accept` headers to `application/vnd.api+json`
- Request interceptor: attach bearer token from auth store (if present)
- Response interceptor: on 401, clear token from auth store and redirect to `/login`
- Export the instance as default

### 4. TypeScript Types

Create `src/types/jsonapi.ts` with shared JSON:API interfaces:
- `JsonApiResource` — `{ type: string, id: string, attributes: Record<string, unknown>, relationships?: Record<string, unknown> }`
- `JsonApiDocument` — `{ data: JsonApiResource | JsonApiResource[] }`
- `JsonApiError` — `{ status: string, code: string, title: string, detail: string, source?: { pointer: string } }`
- `JsonApiErrorResponse` — `{ errors: JsonApiError[] }`
- `CursorMeta` — `{ next: string | null, prev: string | null, count: number, per_page: number }`
- `JsonApiCollectionResponse` — `{ data: JsonApiResource[], meta: { cursor: CursorMeta } }`

Create `src/types/user.ts`:
- `User` — `{ id: string, email: string, email_verified_at: string | null }`

### 5. Auth Store

Create `src/stores/useAuthStore.ts` using Pinia setup/function syntax (`defineStore('auth', () => { ... })`):
- `token: ref<string | null>` — persisted to `localStorage`
- `currentUser: ref<User | null>`
- `isAuthenticated: computed(() => !!token.value)`
- `setToken(t: string)` — saves token to state and localStorage
- `clearAuth()` — clears token, currentUser, and localStorage
- Hydrate token from localStorage on store initialization

### 6. Auth API Client

Create `src/api/auth.ts` with functions that wrap the Axios client:
- `login(email: string, password: string)` — `POST /api/v1/auth/login`
- `register(email: string, password: string, passwordConfirmation: string)` — `POST /api/v1/auth/register`
- `logout()` — `POST /api/v1/auth/logout`
- `getMe()` — `GET /api/v1/auth/me`

Each function wraps the request in JSON:API format and unwraps the response. These will be stubbed (the auth API endpoints don't exist yet — they are part of the auth feature spec).

### 7. Router Setup

Configure `src/router/index.ts`:
- `beforeEach` guard: if route has `meta.requiresAuth` and user is not authenticated, redirect to `/login`
- `beforeEach` guard: if route has `meta.guest` and user is authenticated, redirect to `/` (home)
- Define initial routes:
  - `/login` — `LoginView.vue` (meta: `{ guest: true }`)
  - `/register` — `RegisterView.vue` (meta: `{ guest: true }`)
  - `/` — `HomeView.vue` (meta: `{ requiresAuth: true }`)

### 8. Placeholder Views

Create minimal placeholder views for the initial routes so the app compiles and routes work:
- `src/views/LoginView.vue`
- `src/views/RegisterView.vue`
- `src/views/HomeView.vue`

Each should be a simple `<template>` with a heading indicating the page name. These will be replaced when feature specs are implemented.

### 9. Base Components

Create starter base components with Tailwind styling:
- `src/components/BaseButton.vue` — accepts `label`, `type`, `disabled`, `loading` props. Emits `click`. Keyboard accessible.
- `src/components/BaseInput.vue` — accepts `label`, `modelValue`, `type`, `error`, `autocomplete`, `required`, `disabled` props. Emits `update:modelValue`. Includes `<label>`, error message display, ARIA attributes.

Both must be WCAG 2.1 AA compliant with semantic HTML.

### 10. App Layout

Update `src/App.vue`:
- Wrap router-view in a basic layout with `<main>` semantic element
- Remove any default scaffolding from the Vue setup

### 11. Tests

Write tests before implementation (TDD). At minimum:
- API client test: verify base URL, headers, token interceptor, 401 redirect behavior
- Auth API client test: verify request formation for login, register, logout, getMe
- Auth store test: token persistence to localStorage, hydration, clearAuth
- Router test: auth guard redirects unauthenticated to login, guest guard redirects authenticated to home
- Component test for BaseButton: rendering, click event, disabled state, keyboard accessibility
- Component test for BaseInput: rendering, v-model binding, error display, label association, autocomplete attribute
- Accessibility test for BaseButton and BaseInput: axe-core passes WCAG 2.1 AA

---

## Verification

After implementation, the following should all pass:
- `cd api && ./vendor/bin/sail test` — all API tests green
- `cd web && docker compose exec vue npm run test:unit` — all web tests green
- `cd web && docker compose exec vue npm run type-check` — no TypeScript errors
- API returns proper JSON:API error responses for invalid requests
- Web app boots, routes work, auth guard redirects correctly
