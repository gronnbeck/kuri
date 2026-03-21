# Kuri

A personal Japanese language learning app built with Rails 8.

## Features

- **Practice** — interactive exercises for building Japanese reading and writing skills
  - Sentence Patterns
  - Guided Translation
  - Sentence Transformation
  - Daily Conversations (AI roleplay scenarios)
  - Useful Phrases
  - Micro Sentences
  - Word Guess
- **Listen** — generate and replay Japanese audio clips via ElevenLabs TTS
  - Clips are cached per sentence + voice, so the API is only called once per unique combination
  - Manage named actors (voices) under Settings › Listen › Actors
- **Notes** — browse Anki notes synced from AnkiConnect
- **Decks** — manage Anki deck sync

## Stack

- Ruby on Rails 8.1
- SQLite3 (main · cache · queue · cable)
- Hotwire (Turbo + Stimulus)
- Import Maps (no JS build step)
- Phlex views
- Solid Queue / Cache / Cable
- Kamal (deployment)

## Setup

```bash
bin/setup      # install deps, create DB, seed
bin/dev        # start development server
```

## Environment Variables

Copy `.env.example` to `.env` and fill in values:

```
PSI_ANTHROPIC_API_KEY=   # Anthropic API key for AI practice exercises
PSI_MODEL=               # Claude model (default: claude-haiku-4-5-20251001)
PSI_BIN=                 # Path to the psi binary
ELEVENLABS_API_KEY=      # ElevenLabs API key for audio generation
ELEVENLABS_VOICE_ID=     # Default voice ID (optional, set per actor in UI)
```

## Development

```bash
bin/ci           # full CI pipeline (lint + security + tests)
bin/rails test   # run tests
bin/rubocop      # lint Ruby
```

## Deployment

Deployed via Kamal. See `config/deploy.yml`.

```bash
kamal deploy
```
