# Tasks

## Next
- [ ] Add `NotesController#show` action + route + view for note detail page (front/back/tags/all fields)
- [ ] Limit index card display to Word and Definition fields only (strip other fields from index view)

## Backlog
- [ ] Pagination or infinite scroll for large decks
- [ ] Field selection — let user pick which note fields to display
- [ ] Search / filter notes by tag or query on the index page
- [ ] Local cache model to support offline browsing
- [ ] Support multiple decks (not just "Personal mining")

## Done
- [x] Display notes as cards on index (card-style CSS layout, each card links to detail page) — added CSS grid card layout, updated index view with `.note-card` links, added `resources :notes` route
- [x] Handle AnkiConnect unavailable gracefully (rescue + flash error in `NotesController#index`) — rescued ConnectionError in index action, set flash.now[:alert], assigned @notes=[], added flash rendering to layout
- [x] Create `AnkiConnect::Client` service object with `find_notes(deck:)` and `notes_info(ids:)` methods — created app/services/anki_connect/client.rb using Net::HTTP with ConnectionError handling
- [x] Add `NotesController#index` action that calls the service and renders notes — created app/controllers/notes_controller.rb, app/views/notes/index.html.erb, and set root route
