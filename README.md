# Project API

Ruby on Rails API using Ruby 3.4.9, PostgreSQL, and Sidekiq for local background jobs.

## Local development with Docker Compose

Requirements: Docker Engine or Docker Desktop with the Compose plugin.

```sh
docker compose up --build
```

The Rails API is available at `http://localhost:3002`; PostgreSQL and Redis are reachable to other containers as `db:5432` and `redis:6381`. PostgreSQL is also published to the host on `127.0.0.1:5433` by default (change `POSTGRES_PORT` in `.env` if needed). Compose stores database and Redis data in named volumes.

To stop the services, run `docker compose down`. This keeps the named data volumes. Do not use `docker compose down -v` unless you intend to permanently delete local database and Redis data.

## Motor Admin

The platform administrator dashboard is available at `http://localhost:3002/admin`, with sign-in at `http://localhost:3002/users/sign_in`. Only active users marked as platform administrators can authenticate for the dashboard. Set `ADMIN_USER_PASSWORD` in your untracked `.env` file when creating or repairing the seeded administrator. Set `ADMIN_USER_EMAIL` if the administrator uses an address other than `admin@example.com`, then run `bin/rails db:seed`.

Set `SIDEKIQ_CONCURRENCY` in your local `.env` to tune worker concurrency. Keep `.env` local and never commit its credentials or use them in production.

## Tests and lint

```sh
bin/rails test
bin/rubocop
```

Production queue and cache settings remain in the Rails production configuration and should be supplied with production-specific environment values.
