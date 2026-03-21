# frozen_string_literal: true

require "net/http"
require "json"

class ElevenLabsTts
  MODEL_ID = "eleven_multilingual_v2"

  def self.call(text, voice_id:)
    new(text, voice_id: voice_id).call
  end

  def initialize(text, voice_id:)
    @text     = text
    @voice_id = voice_id
    @api_key  = ENV.fetch("ELEVENLABS_API_KEY") { raise "ELEVENLABS_API_KEY not set" }
  end

  def call
    uri = URI("https://api.elevenlabs.io/v1/text-to-speech/#{@voice_id}")
    request = Net::HTTP::Post.new(uri)
    request["xi-api-key"]   = @api_key
    request["Content-Type"] = "application/json"
    request.body = {
      text:           @text,
      model_id:       MODEL_ID,
      voice_settings: { stability: 0.75, similarity_boost: 0.75 }
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    unless response.is_a?(Net::HTTPSuccess)
      raise "ElevenLabs API error #{response.code}: #{response.body}"
    end

    response.body
  end
end
