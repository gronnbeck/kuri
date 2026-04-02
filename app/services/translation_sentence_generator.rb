# frozen_string_literal: true

class TranslationSentenceGenerator
  include PsiCallable
  MAX_RETRIES = 3

  Result = Struct.new(:english, :japanese, keyword_init: true)

  PROMPT = <<~PROMPT
    You are creating beginner Japanese learning material.
    Generate ONE new short English sentence paired with its Japanese translation.

    Rules:
    - Maximum 7 words in English
    - Simple present tense only
    - Use common everyday vocabulary (food, school, home, hobbies)
    - No idioms, no complex grammar
    - Must be different from these existing sentences:
    %s

    Respond with JSON only — no markdown, no explanation:
    {"english": "...", "japanese": "..."}
  PROMPT

  def self.call
    new.call
  end

  def call
    MAX_RETRIES.times do
      existing = TranslationSentence.pluck(:english)
      result = generate(existing)

      next if TranslationSentence.exists?([ "LOWER(english) = ?", result.english.downcase ])

      return TranslationSentence.create!(english: result.english, japanese: result.japanese)
    end

    raise "Could not generate a unique sentence after #{MAX_RETRIES} attempts"
  end

  private

  def generate(existing)
    existing_list = existing.map { |s| "- #{s}" }.join("\n")
    prompt = format(PROMPT, existing_list)
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
      japanese: data["japanese"].to_s.strip
    )
  rescue JSON::ParserError => e
    raise "unexpected LLM response format: #{e.message}"
  end

  def run_psi(prompt)
    Bundler.with_unbundled_env do
      stdout, stderr, _status = Open3.capture3(psi_env, PSI_BIN, "--pp", *PSI_NO_TOOLS_FLAGS, stdin_data: prompt)
      [ stdout, stderr ]
    end
  rescue Errno::ENOENT
    raise "psi not found at #{PSI_BIN}. Set PSI_BIN env var."
  end
end
