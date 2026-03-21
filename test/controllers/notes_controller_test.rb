# frozen_string_literal: true

require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @deck = Deck.create!(name: "Test Deck")
    @note = Note.create!(
      anki_id: 42,
      deck: @deck,
      fields: { "Word" => { "value" => "Hello" }, "Definition" => { "value" => "World" } },
      tags: [ "tag1", "tag2" ]
    )
  end

  test "index renders notes from the database" do
    get notes_path

    assert_response :success
    assert_select ".note-card", 1
    assert_select ".note-card[href='/notes/42']"
    assert_select ".note-field", /Hello/
  end

  test "index renders empty list when there are no notes" do
    @note.destroy

    get notes_path

    assert_response :success
    assert_select ".note-card", 0
  end

  test "show renders note detail with all fields and tags" do
    get note_path(@note.anki_id)

    assert_response :success
    assert_select ".note-field", /Word/
    assert_select ".note-field", /Definition/
    assert_select ".note-tags", /tag1/
  end

  test "show redirects when note is not found" do
    get note_path(99999)

    assert_redirected_to notes_path
  end
end
