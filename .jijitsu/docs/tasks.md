# Tasks

## Next
- [ ] Handle AnkiConnect unavailable gracefully (rescue + flash error in `NotesController#index`)

## Backlog
- [ ] Card navigation — click a note on the index to view full card detail (front/back/tags)
- [ ] Pagination or infinite scroll for large decks
- [ ] Field selection — let user pick which note fields to display
- [ ] Search / filter notes by tag or query on the index page
- [ ] Local cache model to support offline browsing
- [ ] Support multiple decks (not just "Personal mining")

## Done
- [x] Create `AnkiConnect::Client` service object with `find_notes(deck:)` and `notes_info(ids:)` methods — created app/services/anki_connect/client.rb using Net::HTTP with ConnectionError handling
- [x] Add `NotesController#index` action that calls the service and renders notes — created app/controllers/notes_controller.rb, app/views/notes/index.html.erb, and set root route
