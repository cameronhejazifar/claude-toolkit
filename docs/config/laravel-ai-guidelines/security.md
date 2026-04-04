# Security and Error Handling

## Sanctum

- Personal access tokens via `auth:sanctum` middleware
- No token abilities — all tokens have full access
- Tokens don't expire — revoked on logout or password reset

## CORS

Origins from `CORS_ALLOWED_ORIGINS` env var. Configure `config/cors.php` to read it.

- Methods: `GET, POST, PUT, PATCH, DELETE, OPTIONS`
- Headers: `Content-Type, Authorization, Accept`
- Credentials: `false`
- Local dev: `http://localhost:50301`
- Mobile apps use native HTTP clients — no CORS needed

## Rate Limiting

60 requests/minute per IP/user on all API routes.

## Middleware Stack Order

1. Rate limiting
2. JSON:API content-type validation
3. Sanctum authentication (protected routes)

## Error Handling

Services throw custom exceptions. A global exception handler catches all exceptions and renders JSON:API error responses. Controllers do not handle errors.

### Exception Mapping

| Exception | Code | Status |
|-----------|------|--------|
| `AuthenticationException` | `AUTH_REQUIRED` | 401 |
| `ModelNotFoundException` | `NOT_FOUND` | 404 |
| `AuthorizationException` | `FORBIDDEN` | 403 |
| `ValidationException` | `VALIDATION_FAILED` | 422 |
| `ThrottleRequestsException` | `RATE_LIMITED` | 429 |
| Generic/unhandled | `SERVER_ERROR` | 500 |

### Validation Errors

Each validation error becomes a JSON:API error object: `code: VALIDATION_FAILED`, `detail: validation message`, `source.pointer: /data/attributes/{field}`.

### Custom Exceptions

Create domain-specific exceptions extending a base `ApiException` class. Each specifies: `ErrorCode` enum value, HTTP status, and default message. Examples: `EmailUnverifiedException`, `OwnershipRequiredException`, `StateConflictException`.
