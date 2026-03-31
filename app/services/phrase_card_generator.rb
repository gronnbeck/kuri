# frozen_string_literal: true

class PhraseCardGenerator
  PSI_BIN = ENV.fetch("PSI_BIN", "#{Dir.home}/.local/bin/psi")

  PROMPT = <<~PROMPT
    Generate a Japanese phrase card for a learner at JLPT %s level.

    English phrase: %s
    Context:        %s

    ## Output

    Respond with JSON only — no markdown, no explanation.
    {
      "japanese":  "<natural Japanese translation using kanji appropriate for the JLPT level>",
      "hiragana":  "<hiragana-only reading — every character in hiragana, no kanji or katakana>",
      "notes":     "<optional brief English note about grammar or nuance — null if not needed>"
    }

    Keep the Japanese short and natural. Match the politeness level to the context (ます/です for formal, plain form for casual).
  PROMPT

  Result = Struct.new(:japanese, :hiragana, :notes, keyword_init: true)

  def self.call(english:, context:, difficulty:)
    new(english: english, context: context, difficulty: difficulty).call
  end

  def initialize(english:, context:, difficulty:)
    @english    = english
    @context    = context.presence || "general"
    @difficulty = difficulty
  end

  def call
    prompt = format(PROMPT, @difficulty.upcase, @english, @context)
    stdout, stderr = run_psi(prompt)

    lines = stdout.lines.map { |l| JSON.parse(l.strip) rescue nil }.compact

    if (err = lines.find { |l| l["type"] == "error" })
      raise "psi error: #{err["message"]}"
    end

    response = lines.find { |l| l["type"] == "response" }
    raise "psi failed: #{stderr.lines.first&.strip || "no response"}" unless response

    data = extract_json(response["content"])
    Result.new(
      japanese: data["japanese"].to_s.strip,
      hiragana: data["hiragana"].to_s.strip,
      notes:    data["notes"].presence
    )
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

  def extract_json(content)
    json = content.to_s.strip.gsub(/\A```(?:json)?\n?/, "").gsub(/\n?```\z/, "").strip
    json = json[/\{.*\}/m] || json
    JSON.parse(json)
  rescue JSON::ParserError => e
    raise "unexpected LLM response format: #{e.message}"
  end
end
