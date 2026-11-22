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

The administrator dashboard is available at `http://localhost:3002/admin`. Sign in at `http://localhost:3002/admin_users/sign_in`. The dashboard requires an administrator account; public administrator registration is disabled.

Set `ADMIN_USER_PASSWORD` in your untracked local `.env` file first. After adding the gems or pulling schema changes, rebuild the Rails services, apply migrations, and seed the admin account:

```sh
docker compose up --build -d web sidekiq
docker compose exec web bin/rails db:migrate
docker compose exec web bin/rails db:seed
```

If the web container is already running when you add or change `ADMIN_USER_PASSWORD`, recreate it so Compose passes the value to Rails:

```sh
docker compose up -d --force-recreate web
docker compose exec web bin/rails db:seed
```

The seed creates `admin@example.com` with the configured password, first name `Kevin`, and last name `Hachem`. If the account already exists, it updates the name and updates the password when `ADMIN_USER_PASSWORD` is set. Keep the password in `.env`; never commit `.env` or a real credential.

Set `SIDEKIQ_CONCURRENCY` in your local `.env` to tune worker concurrency. Keep `.env` local and never commit its credentials or use them in production.

## Tests and lint

```sh
bin/rails test
bin/rubocop
```

Production queue and cache settings remain in the Rails production configuration and should be supplied with production-specific environment values.
