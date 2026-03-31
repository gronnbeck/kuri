# frozen_string_literal: true

require "application_system_test_case"

class NoteEnrichmentTest < ApplicationSystemTestCase
  setup do
    @deck = Deck.create!(name: "Test Deck")
    @note = Note.create!(
      anki_id: 1773254410279,
      deck: @deck,
      fields: {
        "Expression" => { "value" => "食べる", "order" => 0 },
        "Reading"    => { "value" => "",       "order" => 1 }
      },
      tags: []
    )
  end

  test "try single page loads and shows form" do
    visit try_single_note_enrichments_path
    assert_selector "h1", text: "Try Enrichment"
    assert_selector "select[name='transformation']"
    assert_selector "textarea[name='source_text']"
    assert_selector "button", text: "Transform"
  end

  test "transformation form is present with expected fields" do
    visit try_single_note_enrichments_path

    assert_selector "select[name='transformation'] option", text: /Reading/
    assert_selector "select[name='transformation'] option", text: /Translate/
    assert_selector "select[name='transformation'] option", text: /Furigana/
    assert_selector "select[name='transformation'] option", text: /Custom prompt/
    assert_selector "textarea[name='source_text']"
    assert_button "Transform"
  end

  test "fetch fields button loads note fields as clickable buttons" do
    visit try_single_note_enrichments_path

    find("[data-fetch-note-fields-target='noteId']").set(@note.anki_id.to_s)
    click_button "Fetch fields"

    assert_selector ".enrichment-load-fields button", text: "Expression"
  end

  test "clicking a field button populates source textarea" do
    visit try_single_note_enrichments_path

    find("[data-fetch-note-fields-target='noteId']").set(@note.anki_id.to_s)
    click_button "Fetch fields"

    find(".enrichment-load-fields button", text: "Expression").click
    assert_field "source_text", with: "食べる"
  end

  test "enrich link on note show page pre-fills the form" do
    visit note_path(@note.anki_id)

    within(".note-field", text: /Expression/) do
      click_link "Enrich →"
    end

    assert_field "source_text", with: "食べる"
  end
end
