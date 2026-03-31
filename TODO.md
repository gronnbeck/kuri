# Kuri — Todo

## Verb Transformation Exercise

Create a new exercise type (similar to Conversations) focused on verb conjugation practice.

- Learner sees a verb in dictionary (infinitive) form and must transform it into a target form (e.g. て-form, た-form, ます-form, potential, passive, etc.)
- Same field structure as Conversation exercises: request, response, translations, readings
- Audio attached to both request and response sides
- Same Anki export support as Conversation exercises

## Batch Card Generation

Generate multiple exercise cards in one go, rather than one at a time.

- Applies to both Conversation Exercises and Verb Transformation Exercises
- User specifies a count (e.g. 10 cards) plus the usual options (difficulty, context/target form, etc.)
- Cards are generated in sequence and saved; user is taken to a review list on completion
- Consider running generations in a background job (Solid Queue) to avoid request timeouts

## Batch Anki Export

Export multiple cards to Anki at once from the index view, rather than one at a time.

- Applies to both Conversation Exercises and Verb Transformation Exercises
- Checkbox selection on the index page, or "Export all unadded" shortcut
- Runs exports in sequence; shows a summary of successes/failures on completion

## Enrich Existing Anki Cards

Add a way to enhance notes already in Anki by transforming one field and writing the result into another.

- Use cases: add a furigana reading field derived from a kanji field; add an English translation field derived from a Japanese field
- User picks a source field, a transformation type (furigana / translate), and a destination field
- Kuri fetches matching notes from AnkiConnect, runs the transformation via AI, and updates the notes in place
- Should work across decks and note types

## Prompt-Only Conversation Card Generation

A dedicated page for generating a single conversation card from a free-form prompt, without selecting a context.

- User sets JLPT level and writes a free-form prompt (e.g. "asking a pharmacist about a medicine")
- Still follows all system rules (learner is always the customer/guest, not the service worker)
- Lives at its own URL so it's easy to reach without going through the batch flow

## Derive New Notes from Existing Ones

Create new Anki cards by reusing content (sentences, audio) already in existing exercises.

- Check whether a word appearing in an exercise sentence already exists in Anki
- If not, use the sentence, audio, and exercise data as the basis for a new card
- Useful for building vocabulary cards out of conversation/verb exercise sentences

## Conversation Card Design — Responsive Fix

The CSS written for the Kuri Anki deck template is not responsive and breaks layout on small screens (e.g. iPhone).

- Fix template CSS so cards render correctly at narrow viewport widths
- Test on mobile-sized screens

## ~~Expose Anki Card Templates in Settings~~ ✓ Done

~~The front/back HTML + CSS templates for Anki cards are currently only stored in Anki and/or the chat history.~~

## Add Users and Tie Resources to Users

Resources are currently global. This needs to be scoped per user before the app can be shared.

- Introduce a User model with authentication (likely Rails built-in `has_secure_password` or similar)
- Audit all resources and decide what is per-user vs. shared (e.g. contexts may be shared; exercises, settings, audio are per-user)
- Add `belongs_to :user` associations and scope all queries accordingly
- Handle seeded/shared data carefully

## Prepare for Deployment via Kamal

The app has a `config/deploy.yml` and `.kamal/secrets` stub but has not been deployed yet.

- Review how other Rails apps in the org are deployed via Kamal
- Ensure `config/deploy.yml` is correct (image, registry, server, env vars)
- Confirm all four SQLite databases are handled with persistent volume mounts
- Set up `APP_URL`, `PSI_ANTHROPIC_API_KEY`, `PSI_MODEL`, `ELEVENLABS_API_KEY` as Kamal secrets
- Do a test deploy to staging/VPS
