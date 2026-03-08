# frozen_string_literal: true

require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  DECK = "Personal mining"

  test "index fetches notes from AnkiConnect and renders them" do
    note_data = [
      { "noteId" => 1, "fields" => { "Front" => { "value" => "Hello" }, "Back" => { "value" => "World" } }, "tags" => [ "tag1" ] }
    ]

    stub_anki_connect("findNotes", { query: "deck:\"#{DECK}\"" }, [ 1 ])
    stub_anki_connect("notesInfo", { notes: [ 1 ] }, note_data)

    get root_path

    assert_response :success
    assert_select "body", /Hello/
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
