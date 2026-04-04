# Project Overview

Monorepo with the following sub-projects:

- `api/` — Laravel 13 API (Sail, Sanctum, Pest)
- `web/` — Vue 3 SPA (Vite, TypeScript, Pinia, Tailwind CSS)
- `ios/` — iOS app (future)
- `android/` — Android app (future)

All clients use `api/` as their backend. Keep future mobile apps in mind for API design decisions.

## Tech Stack

### Backend (`api/`)
PHP 8.5, Laravel 13, MySQL 8.4, Redis, Meilisearch, Composer, Laravel Sail, Sanctum, Guzzle, Pest

### Frontend (`web/`)
TypeScript, Vue 3 (Composition API, `<script setup>`), Vite, Pinia, Vue Router, Tailwind CSS, Axios, Vitest

### Integrations
Email: Resend | Logging: Laravel file logging

### Do NOT Use
- Laravel Mix — use Vite
- Vuex — use Pinia
- Inertia.js — decoupled SPA, not server-rendered
- Blade templates — no server-side HTML rendering
- Sessions or CSRF tokens — use Sanctum bearer tokens
- Component libraries (Vuetify, PrimeVue, Headless UI, Radix, etc.) — build all components from scratch with Tailwind

## Authentication

- Sanctum personal access tokens via `Authorization: Bearer <token>` header
- No cookies, sessions, or CSRF tokens
- Email is the unique user identifier — no usernames

## API Standards

### Versioning
All routes under `/api/v1/`.

### Content Type
`application/vnd.api+json` on all requests and responses.

### JSON:API Format

**Create:**
```json
{
  "data": {
    "type": "posts",
    "attributes": { "title": "My Post", "body": "Hello world." },
    "relationships": {
      "category": { "data": { "type": "categories", "id": "3" } }
    }
  }
}
```

**Update (must include `id`):**
```json
{
  "data": {
    "type": "posts",
    "id": "1",
    "attributes": { "title": "Updated Title" }
  }
}
```

**Success response:**
```json
{
  "data": {
    "type": "users",
    "id": "1",
    "attributes": { "email": "user@example.com" },
    "relationships": {}
  }
}
```

**Collection response:**
```json
{
  "data": [{ "type": "users", "id": "1", "attributes": {} }],
  "meta": {
    "cursor": { "next": "eyJpZCI6MTB9", "prev": null, "count": 10, "per_page": 25 }
  }
}
```

**Error response:**
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

### Error Codes

| Code | Description |
|------|-------------|
| `AUTH_REQUIRED` | No token provided |
| `AUTH_INVALID` | Token is invalid or expired |
| `AUTH_REVOKED` | Token has been revoked |
| `EMAIL_UNVERIFIED` | Email not yet verified |
| `FORBIDDEN` | Authenticated but not permitted |
| `OWNERSHIP_REQUIRED` | Must own the resource |
| `VALIDATION_FAILED` | Input failed validation |
| `INVALID_FORMAT` | Malformed or non-JSON body |
| `NOT_FOUND` | Resource does not exist |
| `ALREADY_EXISTS` | Duplicate resource |
| `GONE` | Resource was deleted |
| `RATE_LIMITED` | Too many requests |
| `SERVER_ERROR` | Unhandled internal error |
| `SERVICE_UNAVAILABLE` | Dependency is down |
| `MAINTENANCE` | App is in maintenance mode |
| `ACTION_NOT_ALLOWED` | Business rules prevent action |
| `STATE_CONFLICT` | Resource state prevents action |

### Pagination
Cursor-based on all list endpoints. Response includes `meta.cursor` with `next`, `prev`, `count`, `per_page`.

### Filtering and Sorting
- Filtering: `?filter[field]=value`
- Sorting: `?sort=-created_at,name` (prefix `-` for descending)

## Development Approach

- **TDD**: Tests are written before implementation. Never comment out or remove a test.
- **Accessibility**: WCAG 2.1 Level AA. Screen readers, color-blindness, keyboard navigation. All inputs have `autocomplete` attributes.
- **Mobile First**: Design using Tailwind breakpoints: `sm` (640px), `md` (768px), `lg` (1024px), `xl` (1280px), `2xl` (1536px). All UI tests must account for these.

### Code Style
- No multiple consecutive blank lines
- No trailing blank lines at end of file
- One blank line between functions/methods, imports and code, and logical sections
- Only use `TODO`/`FIXME` when explicitly implementing a stub or marking a planned feature

### Code Comments
- Every function gets a docblock (PHP: `/** */` with `@param`, `@return`, `@throws`; TypeScript/Vue: JSDoc-style)
- Docblocks describe what the function does, its parameters, return value, and any exceptions
- Document array argument shapes including optional attributes and sub-element types
- For complex logic, add inline comments explaining both what is happening and why
- Simple/self-evident functions only need the docblock — no inline comments required
- All enum values should have a comment describing what they mean

### Git Commits
[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/). Types: `feat`, `fix`, `build`, `chore`, `ci`, `docs`, `style`, `refactor`, `perf`, `test`. Use scope for sub-project: `feat(api): add user registration`.
- Do not include Co-Authored-By lines in commit messages

## Spec-Driven Development

Feature specifications are stored in `docs/specs/` as individual markdown files (e.g., `docs/specs/features.md`, etc). Do not load specs proactively — only read them when a task requires understanding a specific feature's design. Use glob to discover available specs when needed. Before implementing any feature, read the relevant spec file. If no spec exists for the requested feature, stop and ask before proceeding.

## Instructions for Claude

- Make edits directly to files — no code snippets in conversation
- Never push code to a remote
- Never include a library or package without explicit approval. Use `cd api && ./vendor/bin/sail composer require` or `cd web && docker compose exec vue npm install`
- Ask for clarification before implementing ambiguous features
- Never create or merge git branches — work on the current branch
- Never modify `.env` files — suggest changes for the user to make manually
- After significant changes, re-run the Sail environment and verify seeders have run
- Cross-subdirectory changes are allowed when a feature requires it
