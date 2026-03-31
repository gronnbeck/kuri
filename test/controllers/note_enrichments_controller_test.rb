# frozen_string_literal: true

require "test_helper"

class NoteEnrichmentsControllerTest < ActionDispatch::IntegrationTest
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

    # Stub NoteEnricher so no real AI calls are made
    NoteEnricher.define_singleton_method(:call) { |**_| "たべる" }
  end

  # ── try_single GET ───────────────────────────────────────────────────────────

  test "GET try_single renders the form" do
    get try_single_note_enrichments_path
    assert_response :success
  end

  test "GET try_single pre-fills source_text from params" do
    get try_single_note_enrichments_path, params: { source_text: "食べる", transformation: "reading" }
    assert_response :success
    assert_select "textarea[name='source_text']", text: /食べる/
  end

  # ── try_single POST ──────────────────────────────────────────────────────────

  test "POST try_single runs enrichment and shows result" do
    post try_single_note_enrichments_path, params: {
      transformation: "reading",
      source_text: "食べる"
    }
    assert_response :success
    assert_select ".enrichment-result-value", text: /たべる/
  end

  test "POST try_single shows error when enrichment fails" do
    NoteEnricher.define_singleton_method(:call) { |**_| raise "psi failed" }

    post try_single_note_enrichments_path, params: {
      transformation: "reading",
      source_text: "食べる"
    }
    assert_response :success
    assert_select ".enrichment-error-box", text: /psi failed/
  end

  # ── notes#fields JSON endpoint ───────────────────────────────────────────────

  test "GET fields returns note fields as JSON" do
    get fields_note_path(@note.anki_id)
    assert_response :success

    data = JSON.parse(response.body)
    assert_equal @note.anki_id, data["note_id"]
    assert_equal "食べる", data["fields"]["Expression"]
    assert_equal "",       data["fields"]["Reading"]
  end

  test "GET fields returns 404 for unknown note" do
    get fields_note_path(99999999)
    assert_response :not_found

    data = JSON.parse(response.body)
    assert_match(/not found/i, data["error"])
  end

  # ── save_to_anki ─────────────────────────────────────────────────────────────

  test "save_to_note updates local note record and redirects to note page" do
    post save_to_note_note_enrichments_path, params: {
      anki_note_id: @note.anki_id,
      field_name:   "Reading",   # target field
      value:        "たべる"
    }

    assert_redirected_to note_path(@note.anki_id)
    assert_equal "たべる", @note.reload.fields["Reading"]["value"]
  end

  test "save_to_note shows alert when note ID is missing" do
    post save_to_note_note_enrichments_path, params: {
      field_name: "Reading",
      value:      "たべる"
    }
    assert_redirected_to try_single_note_enrichments_path
    assert_match(/missing/i, flash[:alert])
  end

  test "save_to_note shows alert when note is not found" do
    post save_to_note_note_enrichments_path, params: {
      anki_note_id: 99999999,
      field_name:   "Reading",
      value:        "たべる"
    }
    assert_redirected_to try_single_note_enrichments_path
    assert_match(/not found/i, flash[:alert])
  end
end
