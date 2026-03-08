# Technical Spec

## Models

No local persistence required for the initial feature — notes are fetched on demand from AnkiConnect.

Future: a local cache model (e.g. `Note`) could mirror Anki data for offline use.

## APIs

### AnkiConnect
- AnkiConnect exposes a local HTTP API on `http://localhost:8765`.
- Use the `findNotes` action with a query (e.g. `deck:"Personal mining"`) to retrieve note IDs.
- Use the `notesInfo` action with the returned IDs to fetch note fields and tags.
- Requests are JSON POST to `http://localhost:8765` with `{ "action": ..., "version": 6, "params": ... }`.

### Rails Integration
- A service object (e.g. `AnkiConnect::Client`) wraps HTTP calls to AnkiConnect.
- The `NotesController#index` action calls the service and assigns results to the view.
- The `NotesController#show` action fetches a single note by ID via `notesInfo` and renders the detail view.
- Index view renders notes as card components (CSS card layout, each card links to `note_path(id)`).
- Use `Net::HTTP` or Faraday for HTTP; no external gem strictly required.

## Patterns & Decisions

- No JavaScript build step — keep any dynamic behaviour in Stimulus or plain Turbo.
- AnkiConnect errors (Anki not running, network timeout) should be caught and shown as a user-friendly flash message rather than a 500.
- Do not store Anki credentials or API keys — AnkiConnect runs locally and requires no auth by default.
