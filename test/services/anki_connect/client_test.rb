# frozen_string_literal: true

require "test_helper"

class AnkiConnect::ClientTest < ActiveSupport::TestCase
  setup do
    @client = AnkiConnect::Client.new
  end

  test "find_notes sends findNotes action with deck query" do
    stub_request = stub_anki_connect(
      action: "findNotes",
      params: { query: 'deck:"Personal mining"' },
      result: [ 1234, 5678 ]
    )

    ids = @client.find_notes(deck: "Personal mining")

    assert_equal [ 1234, 5678 ], ids
    assert_requested stub_request
  end

  test "notes_info sends notesInfo action with ids" do
    note_data = [
      { "noteId" => 1234, "fields" => { "Front" => { "value" => "Q" }, "Back" => { "value" => "A" } }, "tags" => [] },
      { "noteId" => 5678, "fields" => { "Front" => { "value" => "Q2" }, "Back" => { "value" => "A2" } }, "tags" => [ "kanji" ] }
    ]

    stub_request = stub_anki_connect(
      action: "notesInfo",
      params: { notes: [ 1234, 5678 ] },
      result: note_data
    )

    notes = @client.notes_info(ids: [ 1234, 5678 ])

    assert_equal note_data, notes
    assert_requested stub_request
  end

  test "raises ConnectionError when AnkiConnect is unreachable" do
    stub_request(:post, "http://localhost:8765").to_raise(Errno::ECONNREFUSED)

    assert_raises(AnkiConnect::Client::ConnectionError) do
      @client.find_notes(deck: "Personal mining")
    end
  end

  private

  def stub_anki_connect(action:, params:, result:)
    stub_request(:post, "http://localhost:8765")
      .with(body: hash_including("action" => action, "version" => 6, "params" => params))
      .to_return(
        status: 200,
        body: { result: result, error: nil }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end
end
