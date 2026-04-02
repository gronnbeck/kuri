# frozen_string_literal: true

# Transforms a single text value using an AI-powered transformation.
#
# Supported transformations:
#   reading   — convert Japanese text to hiragana-only reading
#   translate — translate Japanese text to English
#   furigana  — annotate kanji with hiragana readings using 漢字[よみ] format
class NoteEnricher
  include PsiCallable

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
      Add furigana to the following Japanese text using the format 漢字[よみ].
      Every kanji (or kanji compound) must be annotated inline: e.g. 醜態[しゅうたい], 日本語[にほんご].
      Leave hiragana and katakana as-is.
      Output only the annotated text, no explanation.

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
      stdout, stderr, _status = Open3.capture3(psi_env, PSI_BIN, "--pp", *PSI_NO_TOOLS_FLAGS, stdin_data: prompt)
      [ stdout, stderr ]
    end
  rescue Errno::ENOENT
    raise "psi not found at #{PSI_BIN}. Set PSI_BIN env var."
  end
end
