# frozen_string_literal: true

class WordTranslator
  include PsiCallable

  Result = Struct.new(:japanese, :furigana, :description, keyword_init: true)

  PROMPT = <<~PROMPT
    You are a Japanese dictionary for beginner learners.
    Look up the English word "%s" and respond with JSON only — no markdown, no explanation.

    Use this exact structure:
    {
      "japanese": "<kanji/kana form — e.g. 食べる or コーヒー>",
      "furigana": "<hiragana reading — e.g. たべる>",
      "description": "<short English gloss — e.g. to eat (verb)>"
    }

    Rules:
    - Prefer the most common beginner-friendly form
    - If the word is purely katakana (loanword), furigana may repeat it in hiragana
    - Keep description to one short phrase
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

    data = JSON.parse(response["content"].strip.gsub(/\A```(?:json)?\n?/, "").gsub(/\n?```\z/, ""))
    Result.new(
      japanese:    data["japanese"].to_s.strip,
      furigana:    data["furigana"].to_s.strip,
      description: data["description"].to_s.strip
    )
  rescue JSON::ParserError => e
    raise "unexpected LLM response format: #{e.message}"
  end

  private

  def run_psi(prompt)
    Bundler.with_unbundled_env do
      stdout, stderr, _status = Open3.capture3(psi_env, PSI_BIN, "--pp", stdin_data: prompt)
      [ stdout, stderr ]
    end
  rescue Errno::ENOENT
    raise "psi not found at #{PSI_BIN}. Set PSI_BIN env var."
  end
end
