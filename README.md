# Project API

Ruby on Rails API using Ruby 3.4.13, PostgreSQL, and Sidekiq for local background jobs.

## Local development with Docker Compose

Requirements: Docker Engine or Docker Desktop with the Compose plugin.

```sh
docker compose up --build
```

The Rails API is available at `http://localhost:3002`; PostgreSQL and Redis are reachable to other containers as `db:5432` and `redis:6381`. PostgreSQL is also published to the host on `127.0.0.1:5433` by default (change `POSTGRES_PORT` in `.env` if needed). Compose stores database and Redis data in named volumes. For a direct local Rails run, use `bin/rails server -p 3002`.

Set `FRONTEND_ORIGINS` in `.env` to a comma-separated list of approved browser origins (default: `http://localhost:3001`). Set it to the deployed frontend origin when deploying. CORS allows the API's JSON methods and the `Authorization` and `X-CSRF-Token` headers; credentials are not enabled because API authentication uses bearer tokens.

To stop the services, run `docker compose down`. This keeps the named data volumes. Do not use `docker compose down -v` unless you intend to permanently delete local database and Redis data.

## Motor Admin

The platform administrator dashboard is available at `http://localhost:3002/admin`, with sign-in at `http://localhost:3002/users/sign_in`. Only active users marked as platform administrators can authenticate for the dashboard. Set `ADMIN_USER_PASSWORD` in your untracked `.env` file when creating or repairing the seeded administrator. Set `ADMIN_USER_EMAIL` if the administrator uses an address other than `admin@example.com`, then run `bin/rails db:seed`.

## Account API

Interactive Swagger UI is available at `http://localhost:3002/docs/`; the OpenAPI 3.0 document is at `http://localhost:3002/openapi.yaml`. Apipie documentation remains available at `http://localhost:3002/apipie`. These URLs are served from the same host after deployment, so the deployed API host is the public API URL to configure in the frontend. The versioned REST endpoints support passwordless email verification:

- `POST /api/v1/users` creates an unverified account and issues a sign-up code.
- `POST /api/v1/sessions` requests a sign-in code for an existing verified account.
- `POST /api/v1/email_verifications` resends a code for `sign_up` or `sign_in`.
- `PATCH /api/v1/email_verifications/:id` verifies the six-digit code and creates a session.
- `GET /api/v1/me` returns the authenticated user's profile using the session bearer token.
- `GET /api/v1/sessions/:id` returns the current session; `DELETE` revokes it.

In development and test, verification codes are fixed to `000000` and email delivery is skipped. Other environments generate random codes and deliver them by email. Configure `MAILER_FROM`, `SMTP_ADDRESS`, `SMTP_PORT`, `SMTP_DOMAIN`, `SMTP_USERNAME`, and `SMTP_PASSWORD` for both the web and Sidekiq services when enabling email delivery. Session tokens are returned once and stored as digests. Browser sessions also return a CSRF token required in the `X-CSRF-Token` header for state-changing authenticated requests. Sessions expire after 30 minutes of inactivity and no later than 30 days after creation.

Set `SIDEKIQ_CONCURRENCY` in your local `.env` to tune worker concurrency. Keep `.env` local and never commit its credentials or use them in production.

## Tests and lint

```sh
bin/rails test
bin/rubocop
```

Production queue and cache settings remain in the Rails production configuration and should be supplied with production-specific environment values.
