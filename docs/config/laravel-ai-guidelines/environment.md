# Environment Variables

Expected variables in `api/.env`:

| Variable | Description | Default |
|----------|-------------|---------|
| `APP_PORT` | Laravel app port | `50300` |
| `VITE_PORT` | Vite dev server port (Sail proxy) | `50301` |
| `FORWARD_DB_PORT` | MySQL exposed port | `50302` |
| `FORWARD_REDIS_PORT` | Redis exposed port | `50303` |
| `FORWARD_MEILISEARCH_PORT` | Meilisearch exposed port | `50304` |
| `FORWARD_MAILPIT_PORT` | Mailpit SMTP port | `50305` |
| `FORWARD_MAILPIT_DASHBOARD_PORT` | Mailpit UI port | `50306` |
| `CORS_ALLOWED_ORIGINS` | Allowed CORS origins | `http://localhost:50301` |
| `MAIL_MAILER` | Mail driver | `smtp` (local) / `resend` (prod) |
