# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Kuri is a Ruby on Rails 8.1 application using SQLite3, Hotwire (Turbo + Stimulus), and Import Maps (no JS build step). Background jobs, caching, and Action Cable all use database-backed Solid Queue/Cache/Cable adapters.

## Commands

```bash
bin/setup            # Initial setup (creates DB, installs deps, starts server)
bin/dev              # Start development server
bin/ci               # Run full CI pipeline (lint, security scans, tests)
```

**Testing:**
```bash
bin/rails test                      # Run all tests
bin/rails test test/models/foo_test.rb  # Run a single test file
bin/rails test:system               # Run system tests (Capybara/Selenium)
```

**Linting:**
```bash
bin/rubocop          # Lint Ruby (rubocop-rails-omakase style)
```

**Security:**
```bash
bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error
bin/bundler-audit
bin/importmap audit
```

## Architecture

**Stack:** Rails 8.1 · SQLite3 · Propshaft · Import Maps · Hotwire (Turbo + Stimulus) · Solid Queue/Cache/Cable · Kamal (Docker deployment)

**Key design decisions:**
- No JavaScript build step — JS is loaded via Import Maps (`config/importmap.rb`). Add new packages with `bin/importmap pin`.
- Stimulus controllers live in `app/javascript/controllers/`. They are auto-loaded.
- Production uses four SQLite databases: main, cache (`cache.sqlite3`), queue (`queue.sqlite3`), cable (`cable.sqlite3`) — each configured in `config/database.yml`.
- Solid Queue runs inside the Puma process (not a separate worker) — see `config/puma.rb`.
- Deployment via Kamal: `config/deploy.yml` and secrets in `.kamal/secrets`.

**CI pipeline** (`config/ci.rb`) runs: RuboCop → bundler-audit → importmap audit → Brakeman → `rails test` → `db:seed:replant`.

**GitHub Actions** (`.github/workflows/ci.yml`) runs the full CI on PRs and pushes to main.

## Workflow rules

- Always run `bin/ci` and confirm it passes before pushing or committing.
