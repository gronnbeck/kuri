# frozen_string_literal: true

class JpWordTranslator
  include PsiCallable

  Result = Struct.new(:english, :furigana, keyword_init: true)

  PROMPT = <<~PROMPT
    You are a Japanese dictionary for language learners.
    Look up the Japanese word or phrase "%s" and respond with JSON only — no markdown, no explanation.

    {
      "english": "<short English gloss — e.g. 'to drink', 'welcome (polite)', 'how many people?'>",
      "furigana": "<hiragana reading — e.g. のむ, いらっしゃいませ>"
    }

    Keep the English gloss brief (one short phrase). Include grammatical role if helpful (verb, noun, particle, etc.).
  PROMPT

  def self.call(word)
    new(word).call
  end

  def initialize(word)
    @word = word
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
      english:  data["english"].to_s.strip,
      furigana: data["furigana"].to_s.strip
    )
  rescue JSON::ParserError => e
    raise "unexpected LLM response format: #{e.message}"
  end

  protected

  def run_psi(prompt)
    Bundler.with_unbundled_env do
      stdout, stderr, _status = Open3.capture3(psi_env, PSI_BIN, "--pp", stdin_data: prompt)
      [ stdout, stderr ]
    end
  rescue Errno::ENOENT
    raise "psi not found at #{PSI_BIN}. Set PSI_BIN env var."
  end

  private
end
