# Project API

Ruby on Rails API using Ruby 3.4.9, PostgreSQL, and Sidekiq for local background jobs.

## Local development with Docker Compose

Requirements: Docker Engine or Docker Desktop with the Compose plugin.

```sh
docker compose up --build
```

The Rails API is available at `http://localhost:3002`; PostgreSQL and Redis are reachable to other containers as `db:5432` and `redis:6381`. PostgreSQL is also published to the host on `127.0.0.1:5433` by default (change `POSTGRES_PORT` in `.env` if needed). Compose stores database and Redis data in named volumes.

To stop the services, run `docker compose down`. This keeps the named data volumes. Do not use `docker compose down -v` unless you intend to permanently delete local database and Redis data.

Set `SIDEKIQ_CONCURRENCY` in your local `.env` to tune worker concurrency. Keep `.env` local and never commit its credentials or use them in production.

## Tests and lint

```sh
bin/rails test
bin/rubocop
```

Production queue and cache settings remain in the Rails production configuration and should be supplied with production-specific environment values.
