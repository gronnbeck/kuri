# Development Process

> This file is yours to edit. The implementation agent reads it before every task.
> Use it to describe how work should be done in this project: conventions, testing
> requirements, patterns to follow, things to avoid.

## Stack

- Ruby on Rails 8.1, SQLite3, Hotwire (Turbo + Stimulus), Import Maps
- No JS build step — use `bin/importmap pin` for new packages
- Background jobs via Solid Queue (runs inside Puma)
- Frontend using Phlex

## Conventions

- Follow Rails conventions. Prefer thin controllers, fat models.
- Use rubocop-rails-omakase style. Run `bin/rubocop` before considering work done.
- Write tests for new models and controllers. Run `bin/rails test` to verify.
- Prefer editing existing files over creating new ones.
- Keep changes small and focused — one concern per task.

## What to avoid

- Do not introduce raw SQL unless ActiveRecord cannot express the query.
- Do not add gems without a clear reason.
- Do not skip tests for business logic.

## Implementation process

This is the steps we use when implementing a feature

1. Write the test reflecting the spec (test on all levels)
2. Write the code that makes the tests pass
3. Run bin/ci to check that everything is in order
4. Commit
