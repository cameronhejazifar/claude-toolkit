# Web Frontend (Vue 3)

Vue 3 SPA communicating with the Laravel API. Runs on Vite, port 50301.

## Stack

- Vue 3 with Composition API and `<script setup>`
- TypeScript (strict mode)
- Vite, Pinia, Vue Router, Tailwind CSS, Axios, Vitest, `@vue/test-utils`

## Documentation Lookup

Use the Context7 MCP (`mcp__context7`) to look up current documentation before using Vue, Pinia, Vue Router, Tailwind CSS, Vite, Axios, or Vitest APIs. Do not rely on memory for API details.

## Code Style

### TypeScript
- `strict: true` — never disable
- Avoid `any` — prefer `unknown`
- Use `interface` for object shapes; `type` for unions, intersections, aliases
- Single quotes, trailing commas on multi-line structures
- Prefer optional chaining and nullish coalescing over explicit null checks

### Formatting
- 2-space indentation, 100-char line length

### Import Ordering (5 groups, alphabetical within each, separated by blank lines)
1. Vue/framework
2. Third-party libraries
3. Local stores, composables, API clients
4. Local components
5. Types

### File Naming
| Pattern | Convention | Example |
|---------|-----------|---------|
| Components | PascalCase | `BaseButton.vue` |
| Composables | camelCase, `use` prefix | `useAuth.ts` |
| API clients | camelCase | `users.ts` |
| Types | camelCase | `user.ts` |
| Stores | camelCase, `use` prefix + `Store` suffix | `useAuthStore.ts` |

## Commands

Run from `web/` using `docker compose`:

```shell
docker compose up -d              # start (installs deps, runs dev server)
docker compose down               # stop
docker compose exec vue npm run build
docker compose exec vue npm run test:unit
docker compose exec vue npm run type-check
docker compose exec vue npm install <package>  # never edit package.json directly
```

## Vue Style Guide

Follow the [official Vue.js style guide](https://vuejs.org/style-guide/) Priority A and B rules. Key points:

- Multi-word component names, detailed prop definitions with types
- Always `:key` with `v-for`, never `v-if` on same element as `v-for`
- Scoped styles on all components (except `App` and layouts)
- One component per file, PascalCase file names
- Base components prefixed with `Base` (`BaseButton.vue`, `BaseInput.vue`)
- Child components include parent name (`TodoListItem.vue`)
- Self-closing components in templates, PascalCase usage
- SFC order: `<script setup>` → `<template>` → `<style scoped>`
- Order `<script setup>` content: imports → props → emits → composables → reactive state → computed → methods → lifecycle
- Do not use element selectors in `<style scoped>` — use class selectors for performance
- No implicit parent-child communication — no `$parent`, no mutating props, always use `defineEmits()` and props

## State Management (Pinia)

- One store per domain concept (auth, users, cart)
- Setup syntax (function style) with `defineStore`
- Store IDs: simple camelCase (`'auth'`, `'shoppingCart'`) — no dot notation
- State: `ref()`, Getters: `computed()` (prefix `is`/`has` for booleans), Actions: plain functions
- Auth store manages the Sanctum bearer token
- Store files: `src/stores/use[Name]Store.ts`
- Never use Options API or Vuex

## Axios Configuration

- Base URL from `import.meta.env.VITE_API_URL`
- `Content-Type` and `Accept` headers set to `application/vnd.api+json`
- Request interceptor: attach bearer token from auth store
- Response interceptor: handle 401 globally (clear token, redirect to login)
- All other error handling by the calling function

## API Client Layer

One file per resource in `src/api/`:

```
src/api/
├── client.ts     ← Axios instance, interceptors
├── auth.ts       ← Login, register, logout
├── users.ts      ← User CRUD
└── posts.ts      ← Post CRUD
```

- Export named functions, not classes
- Functions wrap payloads in JSON:API format and unwrap responses
- Return the `data` object — callers don't dig into `response.data.data`
- Define TypeScript interfaces for payloads and responses in `src/types/`

## Routing (Vue Router)

- Auth-guarded routes: `meta: { requiresAuth: true }`
- `beforeEach` guard checks auth store; redirects unauthenticated to login
- `beforeEnter` for route-specific checks
- Redirect authenticated users away from login/register

## Testing

### Component Tests (Vitest + @vue/test-utils)
- Co-locate in `__tests__/` next to components: `ComponentName.test.ts`
- Test rendering, interactions, and emitted events
- Mock Pinia with `createTestingPinia()`

### API Client Tests
- Mock Axios at module level
- Test request formation (URL, headers, token), response parsing, error handling, 401 redirect

### Accessibility Tests
- `axe-core` integration in Vitest for WCAG 2.1 AA per component
- Test layouts at each breakpoint
- Test keyboard navigation: focus, tab order, enter/escape

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `VITE_API_URL` | Laravel API base URL | `http://localhost:50300` |
| `VITE_APP_NAME` | App display name | — |
