# frozen_string_literal: true

class WordGuesser
  PSI_BIN = ENV.fetch("PSI_BIN", "#{Dir.home}/.local/bin/psi")

  PROMPT = <<~PROMPT
    You are playing a Japanese vocabulary guessing game.
    The user describes a Japanese word or expression without saying the word itself.
    Guess the single Japanese word being described.
    Respond with ONLY the Japanese word — no explanation, no romaji, no punctuation.

    Description: %s
  PROMPT

  def self.call(description)
    new(description).call
  end

  def initialize(description)
    @description = description
  end

  def call
    prompt = format(PROMPT, @description)
    env = build_env

    stdout, stderr, _status = Bundler.with_unbundled_env do
      Open3.capture3(env, PSI_BIN, "--pp", stdin_data: prompt)
    end

    lines = stdout.lines.map { |l| JSON.parse(l.strip) rescue nil }.compact

    if (err = lines.find { |l| l["type"] == "error" })
      raise "psi error: #{err["message"]}"
    end

    response = lines.find { |l| l["type"] == "response" }
    raise "psi failed: #{stderr.lines.first&.strip || "no response"}" unless response

    response["content"].strip
  rescue Errno::ENOENT
    raise "psi not found at #{PSI_BIN}. Set PSI_BIN env var."
  end

  private

  def build_env
    {
      "PSI_ANTHROPIC_API_KEY" => ENV["PSI_ANTHROPIC_API_KEY"],
      "PSI_MODEL"             => ENV.fetch("PSI_MODEL", "claude-haiku-4-5-20251001")
    }.compact
  end
end
