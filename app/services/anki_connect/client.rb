# frozen_string_literal: true

require "net/http"
require "json"

module AnkiConnect
  class Client
    class ConnectionError < StandardError; end

    DEFAULT_URL = "http://localhost:8765"
    VERSION = 6

    def initialize(url: DEFAULT_URL)
      @endpoint = URI(url)
    end

    def deck_names
      request("deckNames")
    end

    def model_names
      request("modelNames")
    end

    def model_field_names(model_name)
      request("modelFieldNames", modelName: model_name)
    end

    def find_notes(deck:)
      request("findNotes", query: "deck:\"#{deck}\"")
    end

    def notes_info(ids:)
      request("notesInfo", notes: ids)
    end

    def add_note(deck:, note_type:, fields:, audio: [], tags: [])
      note = {
        deckName:  deck,
        modelName: note_type,
        fields:    fields,
        tags:      tags
      }
      note[:audio] = audio if audio.any?
      result = request("addNote", note: note)
      raise "AnkiConnect rejected note: #{result.inspect}" if result.nil?
      result
    end

    private

    def request(action, params = {})
      body = { action: action, version: VERSION, params: params }.to_json
      http_post(body)
    end

    def http_post(body)
      http = Net::HTTP.new(@endpoint.host, @endpoint.port)
      http.open_timeout = 5
      http.read_timeout = 10

      req = Net::HTTP::Post.new(@endpoint.path.presence || "/")
      req["Content-Type"] = "application/json"
      req.body = body

      response = http.request(req)
      data = JSON.parse(response.body)
      raise "AnkiConnect error: #{data["error"]}" if data["error"]
      data["result"]
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Net::OpenTimeout, SocketError => e
      raise ConnectionError, "AnkiConnect unavailable: #{e.message}"
    end
  end
end
