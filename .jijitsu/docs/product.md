# Product Spec

## Concept

Kuri is a personal note-browsing app that surfaces Anki cards from a user's collection on a web index page.

## Features

### Index — List Notes from Personal Mining
- The index page displays all notes from the user's "Personal mining" Anki deck.
- Notes are fetched live via AnkiConnect (Anki's local HTTP API).
- The user can see their mined notes without opening Anki directly.

## Open Questions

- Should notes be read-only, or can they be edited/deleted from Kuri?
- What fields should be displayed per note (front, back, tags, all fields)?
- Should notes be paginated or infinite-scrolled?
- What happens when Anki is not running (AnkiConnect unavailable)?
