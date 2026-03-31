# frozen_string_literal: true

# Transforms a single text value using an AI-powered transformation.
#
# Supported transformations:
#   reading   — convert Japanese text to hiragana-only reading
#   translate — translate Japanese text to English
#   furigana  — annotate kanji with hiragana readings as HTML <ruby> tags
class NoteEnricher
  PSI_BIN = ENV.fetch("PSI_BIN", "#{Dir.home}/.local/bin/psi")

  PROMPTS = {
    "reading" => <<~PROMPT,
      Convert the following Japanese text to a hiragana-only reading.
      Output only the hiragana reading, no kanji or katakana, no explanation.

      Input: %s
    PROMPT

    "translate" => <<~PROMPT,
      Translate the following Japanese text to natural English.
      Output only the English translation, no explanation.

      Input: %s
    PROMPT

    "furigana" => <<~PROMPT
      Add furigana to the following Japanese text using HTML <ruby> tags.
      Every kanji (or kanji compound) must be wrapped: <ruby>漢字<rt>かんじ</rt></ruby>
      Leave hiragana and katakana as-is.
      Output only the annotated HTML, no explanation.

      Input: %s
    PROMPT
  }.freeze

  def self.call(transformation:, source_value:, custom_prompt: nil)
    new(transformation: transformation, source_value: source_value, custom_prompt: custom_prompt).call
  end

  def initialize(transformation:, source_value:, custom_prompt: nil)
    @transformation  = transformation
    @source_value    = source_value
    @custom_prompt   = custom_prompt
  end

  def call
    prompt = if @transformation == "custom"
      raise "Custom prompt is required." if @custom_prompt.blank?
      "#{@custom_prompt}\n\nInput: #{@source_value}"
    else
      format(PROMPTS.fetch(@transformation), @source_value)
    end
    stdout, stderr = run_psi(prompt)
    lines = stdout.lines.map { |l| JSON.parse(l.strip) rescue nil }.compact

    if (err = lines.find { |l| l["type"] == "error" })
      raise "psi error: #{err["message"]}"
    end

    response = lines.find { |l| l["type"] == "response" }
    raise "psi failed: #{stderr.lines.first&.strip || "no response"}" unless response

    response["content"].to_s.strip
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
