# frozen_string_literal: true

class WordTranslator
  PSI_BIN = ENV.fetch("PSI_BIN", "#{Dir.home}/.local/bin/psi")

  PROMPT = <<~PROMPT
    You are a Japanese dictionary.
    Translate the English word "%s" to Japanese.
    Respond with only the Japanese word or short phrase — kanji/kana, no romaji, no explanation.
    If the word has multiple common forms, prefer the most beginner-friendly one.
  PROMPT

  def self.call(word)
    new(word).call
  end

  def initialize(word)
    @word = word.gsub(/[^a-zA-Z0-9'\- ]/, "")
  end

  def call
    prompt = format(PROMPT, @word)
    stdout, stderr = run_psi(prompt)

    lines = stdout.lines.map { |l| JSON.parse(l.strip) rescue nil }.compact

    if (err = lines.find { |l| l["type"] == "error" })
      raise "psi error: #{err["message"]}"
    end

    response = lines.find { |l| l["type"] == "response" }
    raise "psi failed: #{stderr.lines.first&.strip || "no response"}" unless response

    response["content"].strip
  end

  private

  def run_psi(prompt)
    Bundler.with_unbundled_env do
      stdout, stderr, _status = Open3.capture3(build_env, PSI_BIN, "--pp", stdin_data: prompt)
      [ stdout, stderr ]
    end
  rescue Errno::ENOENT
    raise "psi not found at #{PSI_BIN}. Set PSI_BIN env var."
  end

  def build_env
    {
      "PSI_ANTHROPIC_API_KEY" => ENV["PSI_ANTHROPIC_API_KEY"],
      "PSI_MODEL"             => ENV.fetch("PSI_MODEL", "claude-haiku-4-5-20251001")
    }.compact
  end
end
