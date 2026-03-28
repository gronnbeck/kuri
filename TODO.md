# Kuri — Todo

## Verb Transformation Exercise

Create a new exercise type (similar to Conversations) focused on verb conjugation practice.

- Learner sees a verb in dictionary (infinitive) form and must transform it into a target form (e.g. て-form, た-form, ます-form, potential, passive, etc.)
- Same field structure as Conversation exercises: request, response, translations, readings
- Audio attached to both request and response sides
- Same Anki export support as Conversation exercises

## Conversation Card Design — Responsive Fix

The CSS written for the Kuri Anki deck template is not responsive and breaks layout on small screens (e.g. iPhone).

- Fix template CSS so cards render correctly at narrow viewport widths
- Test on mobile-sized screens

## Expose Anki Card Templates in Settings

The front/back HTML + CSS templates for Anki cards are currently only stored in Anki and/or the chat history.

- Add a section in Settings where the card templates are displayed as copyable text blocks
- One block each: Front HTML, Back HTML, CSS
- Copy-to-clipboard button for each

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
