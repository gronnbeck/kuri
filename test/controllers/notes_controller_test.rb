# frozen_string_literal: true

require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  DECK = "Personal mining"

  test "index shows alert and empty list when AnkiConnect is unavailable" do
    stub_request(:post, "http://localhost:8765").to_raise(Errno::ECONNREFUSED)

    get root_path

    assert_response :success
    assert_select "body", /AnkiConnect unavailable/
  end

  test "index fetches notes from AnkiConnect and renders them" do
    note_data = [
      { "noteId" => 1, "fields" => { "Front" => { "value" => "Hello" }, "Back" => { "value" => "World" } }, "tags" => [ "tag1" ] }
    ]

    stub_anki_connect("findNotes", { query: "deck:\"#{DECK}\"" }, [ 1 ])
    stub_anki_connect("notesInfo", { notes: [ 1 ] }, note_data)

    get root_path

    assert_response :success
    assert_select ".note-card", 1
    assert_select ".note-card[href='/notes/1']"
    assert_select ".note-field", /Hello/
  end

  test "show renders note detail with all fields and tags" do
    note_data = [
      { "noteId" => 42, "fields" => { "Front" => { "value" => "Hello" }, "Back" => { "value" => "World" } }, "tags" => [ "tag1", "tag2" ] }
    ]

    stub_anki_connect("notesInfo", { notes: [ 42 ] }, note_data)

    get note_path(42)

    assert_response :success
    assert_select ".note-field", /Hello/
    assert_select ".note-field", /World/
    assert_select ".note-tags", /tag1/
  end

  test "show shows alert when AnkiConnect is unavailable" do
    stub_request(:post, "http://localhost:8765").to_raise(Errno::ECONNREFUSED)

    get note_path(42)

    assert_response :success
    assert_select "body", /AnkiConnect unavailable/
  end

  private

  def stub_anki_connect(action, params, result)
    stub_request(:post, "http://localhost:8765")
      .with(body: hash_including("action" => action, "version" => 6, "params" => params))
      .to_return(
        status: 200,
        body: { result: result, error: nil }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end
end
