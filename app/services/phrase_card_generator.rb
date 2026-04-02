# frozen_string_literal: true

class PhraseCardGenerator
  include PsiCallable

  PROMPT = <<~PROMPT
    Generate a Japanese phrase card for a learner at JLPT %s level.

    %s

    ## Output

    Respond with JSON only — no markdown, no explanation.
    {
      "english":   "<a short, natural English phrase — use the one provided or write one that fits the prompt>",
      "japanese":  "<natural Japanese using kanji appropriate for the JLPT level>",
      "hiragana":  "<hiragana-only reading — every character in hiragana, no kanji or katakana>",
      "notes":     "<optional brief English note about grammar or nuance — null if not needed>"
    }

    Keep the Japanese short and natural. Match the politeness level to the context (ます/です for formal, plain form for casual).
  PROMPT

  Result = Struct.new(:english, :japanese, :hiragana, :notes, keyword_init: true)

  def self.call(prompt:, difficulty:, english: nil)
    new(prompt: prompt, difficulty: difficulty, english: english).call
  end

  def initialize(prompt:, difficulty:, english: nil)
    @prompt     = prompt
    @english    = english.presence
    @difficulty = difficulty
  end

  def call
    prompt = format(PROMPT, @difficulty.upcase, build_request)
    stdout, stderr = run_psi(prompt)

    lines = stdout.lines.map { |l| JSON.parse(l.strip) rescue nil }.compact

    if (err = lines.find { |l| l["type"] == "error" })
      raise "psi error: #{err["message"]}"
    end

    response = lines.find { |l| l["type"] == "response" }
    raise "psi failed: #{stderr.lines.first&.strip || "no response"}" unless response

    data = extract_json(response["content"])
    Result.new(
      english:  data["english"].to_s.strip.presence || @english,
      japanese: data["japanese"].to_s.strip,
      hiragana: data["hiragana"].to_s.strip,
      notes:    data["notes"].presence
    )
  end

  private

  def build_request
    parts = []
    parts << "Prompt: #{@prompt}" if @prompt.present?
    parts << "English phrase: #{@english}" if @english.present?
    parts.any? ? parts.join("\n") : "Generate a useful everyday phrase."
  end

  def run_psi(prompt)
    Bundler.with_unbundled_env do
      stdout, stderr, _status = Open3.capture3(psi_env, PSI_BIN, "--pp", stdin_data: prompt)
      [ stdout, stderr ]
    end
  rescue Errno::ENOENT
    raise "psi not found at #{PSI_BIN}. Set PSI_BIN env var."
  end


  def extract_json(content)
    json = content.to_s.strip.gsub(/\A```(?:json)?\n?/, "").gsub(/\n?```\z/, "").strip
    json = json[/\{.*\}/m] || json
    JSON.parse(json)
  rescue JSON::ParserError => e
    raise "unexpected LLM response format: #{e.message}"
  end
end
