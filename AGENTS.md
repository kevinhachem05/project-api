
# AGENTS.md — Ruby on Rails Backend Development Guidelines

**## Commit Message Convention**

Commits use **\*\*Gitmoji\*\*** prefixes followed by a scope and description:

\`\`\`
\<emoji> \<Scope>: \<description>
\`\`\`

Examples:
\- \`✨ LicenseRequest: add termination fields\`
\- \`🦺 Talent: validate category assignees limit\`
\- \`✅ CompanyUser: add more unit tests\`
\- \`⚡️ Company: populate company_name into Impersona and Talent models\`

**### Emoji Reference**

\| Emoji | Code | Meaning |
\|-------|------|---------|
\| 🎉 | \`:tada:\` | Initial commit |
\| ✨ | \`:sparkles:\` | New feature or class |
\| ⚡️ | \`:zap:\` | Enhancement / performance improvement |
\| 🔧 | \`:wrench:\` | Fix or tweak (non-bug logic update) |
\| 🐛 | \`:bug:\` | Bug fix |
\| 🦺 | \`:safety_vest:\` | Add/update validators or guards |
\| ✅ | \`:white_check_mark:\` | Add or update tests |
\| 🔥 | \`:fire:\` | Remove code or files |
\| 🚚 | \`:truck:\` | Rename or move resources |
\| 🎨 | \`:art:\` | Improve structure / formatting (blueprints, serialization) |
\| 🔍️ | \`:mag:\` | Add search or filter functionality |
\| 🗃️ | \`:card_file_box:\` | Database-related (seeds, fixtures, migrations, data updates) |
\| 🐋 | \`:whale:\` | Docker configuration |
\| 🔐 | \`:closed_lock_with_key:\` | Permissions / authorization logic |
\| 🔒️ | \`:lock:\` | Security / credentials |
\| 🌐 | \`:globe_with_meridians:\` | Internationalization (i18n) |
\| 📃 | \`:page_with_curl:\` | Documentation updates |
\| 📝 | \`:memo:\` | Documentation (alternative) |
\| 🧹 | \`:broom:\` | Code cleanup |
\| ♻️ | \`:recycle:\` | Refactor |
\| ➕ | \`:heavy_plus_sign:\` | Add dependency or tooling |
\| 🚀 | \`:rocket:\` | Deploy / mount service |
\| 📬️ | \`:mailbox_with_mail:\` | Email / mailer related |
\| 🗺️ | \`:world_map:\` | ERD / architecture diagram |

divide the changes into 3 commits for sign up ./ sign in / verification code

## 1. Project Overview

This project is a Ruby on Rails API-only backend serving two frontend applications:

- **Web:** Next.js running on `localhost:3001`
- **Mobile:** React Native / Expo running on port `8081`
- **Backend:** Ruby on Rails running on `localhost:3002`
- **Database:** PostgreSQL

Port `3000` is reserved for other work projects and must not be used by this backend.

The backend must provide a clean, secure, maintainable, and scalable API shared between the web and mobile applications.
ss
## 2. General Development Principles

Whenever implementing a new feature, modifying existing functionality, or fixing a bug:

- Follow Ruby on Rails conventions and established best practices.
- Write clean, readable, maintainable, and reusable code.
- Follow **DRY (Don't Repeat Yourself)**, **SOLID**, and **Separation of Concerns** principles where appropriate.
- Prefer simple solutions over unnecessary abstractions.
- Keep methods short, focused, and descriptive.
- Use meaningful names for classes, methods, variables, and files.
- Avoid deeply nested conditions and unnecessarily complex logic.
- Use guard clauses when they improve readability.
- Avoid duplicated business logic.
- Never introduce unnecessary dependencies.
- Maintain consistency with the existing codebase.
- Prioritize code clarity over clever implementations.
- Do not overengineer simple features.

**Important:** Before implementing anything, inspect the existing project structure and reuse established patterns.

## 3. Required Project Structure

Organize backend code according to its responsibility.

```text
app/
├── controllers/
│   ├── application_controller.rb
│   ├── concerns/
│   └── api/
│       └── v1/
│           ├── base_controller.rb
│           └── ...
│
├── models/
│   ├── concerns/
│   └── ...
│
├── services/
│   └── ...
│
├── queries/
│   └── ...
│
├── policies/
│   └── ...
│
├── serializers/
│   └── ...
│
├── validators/
│   └── ...
│
├── jobs/
│   └── ...
│
├── mailers/
│   └── ...
│
└── helpers/
    └── ...

config/
├── initializers/
├── routes.rb
├── database.yml
└── ...

db/
├── migrate/
├── schema.rb
└── seeds.rb

spec/
├── requests/
├── models/
├── services/
├── policies/
├── factories/
└── support/
```

### Structure Rules

- Create files only in their appropriate directories.
- Do not place business logic inside controllers.
- Do not place unrelated responsibilities inside models.
- Do not create large, monolithic classes.
- Do not create unnecessary folders or files.
- Only introduce a service, query, policy, serializer, or validator when the feature requires it.
- Reuse existing classes and shared functionality whenever appropriate.
- Follow Rails autoloading and naming conventions.
- Keep related functionality grouped logically.

**Never create additional architectural layers without a clear purpose.**

## 4. Controllers

Controllers are responsible for handling HTTP requests and responses.

Controllers should:

- Receive requests.
- Validate and permit parameters.
- Authenticate and authorize users.
- Invoke models or services.
- Return appropriate JSON responses.
- Use appropriate HTTP status codes.

Controllers must not:

- Contain complex business logic.
- Execute large database queries.
- Perform unrelated operations.
- Contain duplicated functionality.
- Become excessively large.

Use RESTful actions whenever possible:

- `index`
- `show`
- `create`
- `update`
- `destroy`

Keep controllers thin and easy to understand.

## 5. Models

Models represent domain entities and manage persistence through Active Record.

Models should contain:

- Associations.
- Validations.
- Relevant scopes.
- Domain-specific behavior.
- Small, cohesive business rules.

Avoid:

- Fat models with unrelated responsibilities.
- Complex external API integrations.
- Large multi-step workflows.
- Unnecessary callbacks.
- Repeated queries.

Use database constraints alongside model validations when appropriate.

Prefer explicit methods over hidden side effects.

## 6. Service Objects

Use service objects for complex business operations involving multiple steps, models, or external integrations.

Store them in:

`app/services/`

Examples:

- `Users::Register`
- `Orders::Create`
- `Payments::Process`

Rules:

- Each service should have one clear responsibility.
- Use descriptive names reflecting the operation.
- Prefer a consistent public interface such as `call`.
- Keep implementation details private when appropriate.
- Handle expected failures explicitly.
- Use transactions when multiple database operations must succeed together.
- Avoid unnecessary service-to-service dependencies.
- Do not create service objects for trivial Active Record operations.

## 7. Query Objects

Use query objects for complex or reusable database queries.

Store them in:

`app/queries/`

Rules:

- Keep database retrieval logic separate from business operations when complexity justifies it.
- Prefer Active Record scopes for simple queries.
- Avoid N+1 queries.
- Use eager loading where necessary.
- Avoid loading unnecessary records or columns.
- Use pagination for large collections.
- Add indexes when supported by actual query requirements.

## 8. Authorization and Policies

Keep authorization separate from authentication and business logic.

Store policies in:

`app/policies/`

Rules:

- Verify permissions before performing protected operations.
- Never trust user IDs, ownership information, or roles supplied by the frontend.
- Enforce resource-level authorization.
- Keep permission logic centralized.
- Use a consistent authorization approach throughout the project.
- Prevent unauthorized access to other users' records.

## 9. API Architecture

All API endpoints must follow a versioned structure.

Base path:

`/api/v1/`

Examples:

- `GET /api/v1/users`
- `GET /api/v1/users/:id`
- `POST /api/v1/users`
- `PATCH /api/v1/users/:id`
- `DELETE /api/v1/users/:id`

Rules:

- Follow RESTful naming conventions.
- Use JSON for API requests and responses.
- Return appropriate HTTP status codes.
- Maintain consistent response formats.
- Provide understandable validation and error messages.
- Avoid exposing internal exceptions or sensitive information.
- Use pagination, filtering, and sorting when appropriate.
- Maintain compatibility with both Next.js and React Native.
- Avoid breaking existing API contracts without an explicit migration plan.

## 10. Serializers and JSON Responses

Use serializers or dedicated presentation objects when response formatting becomes complex or reusable.

Store them in:

`app/serializers/`

Rules:

- Keep response formatting out of complex controller logic.
- Explicitly define exposed fields.
- Avoid returning entire database records unnecessarily.
- Never expose passwords, tokens, or internal secrets.
- Maintain consistent naming conventions.
- Keep API response structures predictable.

Do not introduce a serialization library unless necessary.

## 11. Database and Migrations

Use PostgreSQL and Active Record.

Rules:

- Use migrations for schema changes.
- Use Rails' default auto-incrementing `id` primary key for every table; do not add custom ID generation or manually increment IDs in application code.
- Add foreign keys for relationships where appropriate.
- Add database indexes when necessary.
- Use unique constraints for values requiring uniqueness.
- Use appropriate data types.
- Avoid unnecessary nullable columns.
- Maintain referential integrity.
- Use transactions for atomic operations.
- Never modify historical migrations already applied in shared environments.
- Never perform destructive database operations without explicit approval.
- Avoid unnecessary database queries.

Design the database for maintainability and data integrity.

## 12. Authentication and Security

Security must be considered in every feature.

Rules:

- Use an established authentication approach suitable for both web and mobile clients.
- Secure protected endpoints.
- Apply authorization consistently.
- Validate untrusted inputs.
- Use strong parameters.
- Never hardcode secrets or credentials.
- Never expose sensitive data through API responses or logs.
- Use environment variables or Rails credentials for secrets.
- Protect against SQL injection.
- Apply rate limiting where appropriate.
- Use secure token expiration and revocation mechanisms when applicable.
- Configure CORS to allow only approved browser origins.
- Apply CSRF protections when using cookie-based authentication.

Do not introduce an authentication library or strategy without considering the requirements of both clients.

## 13. Background Jobs

Use Active Job for asynchronous operations.

Store jobs in:

`app/jobs/`

Examples include:

- Sending emails.
- Processing uploaded files.
- Synchronizing external data.
- Performing long-running tasks.

Rules:

- Keep jobs focused.
- Avoid unnecessary background processing.
- Handle retries and failures.
- Design jobs to be idempotent where possible.
- Never block HTTP requests with unnecessary long-running operations.
- Use the project's configured job adapter.

## 14. Error Handling

Handle errors consistently throughout the API.

Rules:

- Use meaningful error messages.
- Return appropriate HTTP status codes.
- Handle expected validation and domain failures explicitly.
- Do not silently ignore exceptions.
- Do not expose stack traces to clients.
- Log unexpected failures appropriately.
- Avoid rescuing every exception indiscriminately.
- Keep error-handling patterns consistent.

## 15. Testing and Code Quality

Every meaningful feature should include appropriate tests.

Use the existing test framework. For a new project, prefer RSpec if it is selected during setup.

Organize tests under:

`spec/`

Rules:

- Write request specs for API endpoints.
- Write model specs for important validations and domain behavior.
- Write service specs for complex business operations.
- Write policy specs for authorization.
- Test successful and unsuccessful scenarios.
- Test edge cases.
- Keep tests readable and independent.
- Avoid unnecessary mocking.
- Use factories when appropriate.
- Run relevant tests after implementation.

Use RuboCop to maintain consistent Ruby style.

Do not claim that tests pass unless they have actually been executed.

## 16. Readability and Maintainability

Code must be understandable to another developer without extensive explanation.

Always:

- Prefer descriptive names.
- Keep methods focused.
- Extract repeated logic.
- Use consistent formatting.
- Minimize nesting.
- Avoid magic numbers and unexplained constants.
- Keep classes cohesive.
- Use comments only to explain non-obvious decisions.
- Remove unused code.
- Follow existing project conventions.

Avoid:

- Huge methods.
- Unnecessary abstractions.
- Duplicated code.
- Excessive callbacks.
- Complex conditionals when simpler alternatives exist.
- Generic classes with unclear responsibilities.
- Premature optimization.

**Readable code is more important than clever code.**

## 17. Environment and Frontend Integration

Development ports:

- Rails API: `3002`
- Next.js: `3001`
- Expo Metro: `8081`
- Reserved work-project port: `3000`

Rules:

- Keep Rails on port `3002` during local development.
- Never modify the reserved port `3000`.
- Use environment variables for API URLs.
- Configure CORS for approved browser origins.
- Keep backend endpoints independent of frontend implementation details.
- Ensure API contracts work for both web and mobile.
- Do not hardcode local machine IP addresses.
- Remember that physical mobile devices cannot reach the computer's backend using `localhost`.
- Use a configurable LAN address or appropriate development tunnel when needed.

## 18. Feature Implementation Workflow

**Every time a new feature is requested, follow this workflow:**

### Step 1 — Understand the Requirement

- Identify what the feature must accomplish.
- Determine which entities and endpoints are involved.
- Identify authentication and authorization requirements.
- Check whether similar functionality already exists.

### Step 2 — Inspect Existing Code

Before writing code:

- Review relevant routes.
- Review related controllers.
- Review existing models and associations.
- Review services and policies.
- Review relevant migrations.
- Review existing tests.

Never assume a file or component needs to be created before checking whether it already exists.

### Step 3 — Plan the Structure

Determine which files are actually needed.

Possible files include:

- Migration
- Model
- Controller
- Service
- Query
- Policy
- Serializer
- Background job
- Tests

Do not create every file type automatically.

Use only the components necessary for the feature.

### Step 4 — Implement

- Follow existing conventions.
- Keep controllers thin.
- Keep models cohesive.
- Extract complex business operations into services.
- Apply authorization.
- Handle errors appropriately.
- Avoid duplicated code.
- Keep API responses consistent.

### Step 5 — Validate

- Check syntax and autoloading.
- Run relevant tests.
- Run lint checks where configured.
- Verify API routes and response behavior.
- Check for unnecessary queries.
- Verify authorization and security.
- Check compatibility with existing functionality.

### Step 6 — Review

Before finishing:

- Remove unnecessary code.
- Check naming and readability.
- Confirm correct file placement.
- Ensure the implementation is not overengineered.
- Identify potential breaking changes.
- Confirm no unrelated files were modified unnecessarily.

### Step 7 — Summarize

After implementation, briefly explain:

1. What was implemented.
2. Which files were created or modified.
3. Which API endpoints were added or changed.
4. Whether database migrations are required.
5. Which tests were executed and their results.
6. Any remaining setup steps or limitations.

Keep explanations concise and practical.

## 19. Rules for AI Coding Assistants

These instructions apply to every implementation request.

- Always inspect existing code before making changes.
- Always follow the established Rails project structure.
- Never put complex business logic inside controllers.
- Never create unnecessary files.
- Never duplicate existing functionality.
- Never introduce a new architectural pattern without justification.
- Never change unrelated code.
- Never introduce unnecessary gems.
- Never hardcode secrets or credentials.
- Never bypass authorization checks.
- Never perform destructive database operations without approval.
- Never modify the work-project port `3000`.
- Never claim unexecuted tests passed.
- Always prioritize readability, maintainability, and correctness.
- Always consider the impact on both web and mobile applications.
- Always write code that another developer can understand and extend.

## Docker and Local Infrastructure

- Local Docker Compose services are Rails (`web`), PostgreSQL (`db`), Redis, and Sidekiq.
- Use the shared `Dockerfile` for Rails application containers. Keep development and production behavior separated through configuration and environment variables.
- Use Docker service names such as `db` and `redis` for container-to-container connections. Never use `localhost` between containers.
- Use named volumes for PostgreSQL and Redis data. Do not run destructive Docker commands that remove or alter persistent volumes without explicit approval.
- Bind Rails only to `localhost:3002`. Preserve frontend `localhost:3001`, Expo `localhost:8081`, and the reservation of port `3000`.
- Keep `.env` untracked and use `.env.example` for safe variable documentation. Never commit real credentials or populated environment files.
- Keep service responsibilities focused, use health checks for dependencies, and avoid privileged containers and unnecessary published ports.
- Use Sidekiq with Redis for the development Active Job backend. Keep production queue settings appropriate to the deployment configuration.
- Make background jobs retry-safe and idempotent where practical, and handle failures explicitly.
- Before changing Docker configuration, inspect existing files, avoid duplicate infrastructure, preserve ports, and document new variables and startup steps.

## 20. Final Development Standard

Every implementation must be:

- **Structured:** Files belong in the correct directories.
- **Readable:** Code is clear and easy to understand.
- **Maintainable:** Changes can be made without unnecessary complexity.
- **Reusable:** Shared logic is not duplicated.
- **Secure:** Authentication, authorization, and input handling are considered.
- **Testable:** Important behavior can be verified independently.
- **Scalable:** Architecture can grow without premature overengineering.
- **Consistent:** Existing conventions and API contracts are respected.

**The main objective is to build a professional Ruby on Rails backend with clean architecture, organized files, readable code, and a reliable API shared by the web and mobile applications.**

# Generate a model with attributes
rails g model Product name:string price:decimal

# Generate a migration only
rails g migration AddDescriptionToProducts description:text

# Generate a controller and related files
rails g controller Products

# Generate a scaffold (almost everything CRUD-related)
rails g scaffold Product name:string price:decimal
