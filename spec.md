# Kuri

Personal note-browsing app that surfaces Anki cards from the "Personal mining" deck on a web interface.

## Concept

- Browse mined Anki notes without opening Anki. → [Product: Concept](.jijitsu/docs/product.md#concept)
- Notes fetched live via AnkiConnect (local HTTP API on `localhost:8765`). → [Technical: APIs](.jijitsu/docs/technical.md#apis)

## Features

| Feature | Status |
|---|---|
| Index page — list notes as cards (Word + Definition only) | in progress |
| Note detail page — full fields, tags | done |
| AnkiConnect error handling (flash on unavailable) | done |

→ [Full product spec](.jijitsu/docs/product.md) · [Technical spec](.jijitsu/docs/technical.md)

## Next Action

- [ ] Limit index cards to Word and Definition fields only (currently shows full info). → [Tasks](.jijitsu/docs/tasks.md#next)

## References

- [Product spec](.jijitsu/docs/product.md)
- [Technical spec](.jijitsu/docs/technical.md)
- [Tasks](.jijitsu/docs/tasks.md)
