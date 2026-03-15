# frozen_string_literal: true

require "net/http"
require "json"

module AnkiConnect
  class Client
    class ConnectionError < StandardError; end

    ENDPOINT = URI("http://localhost:8765")
    VERSION = 6

    def deck_names
      request("deckNames")
    end

    def find_notes(deck:)
      request("findNotes", query: "deck:\"#{deck}\"")
    end

    def notes_info(ids:)
      request("notesInfo", notes: ids)
    end

    private

    def request(action, params = {})
      body = { action: action, version: VERSION, params: params }.to_json
      http_post(body)
    end

    def http_post(body)
      http = Net::HTTP.new(ENDPOINT.host, ENDPOINT.port)
      http.open_timeout = 5
      http.read_timeout = 10

      req = Net::HTTP::Post.new(ENDPOINT.path.presence || "/")
      req["Content-Type"] = "application/json"
      req.body = body

      response = http.request(req)
      data = JSON.parse(response.body)
      data["result"]
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Net::OpenTimeout, SocketError => e
      raise ConnectionError, "AnkiConnect unavailable: #{e.message}"
    end
  end
end
