# frozen_string_literal: true

class ConversationExerciseGenerator
  PSI_BIN = ENV.fetch("PSI_BIN", "#{Dir.home}/.local/bin/psi")

  Result = Struct.new(:request_jp, :request_en, :request_reading, :response_jp, :response_en, :response_reading, :notes, keyword_init: true)

  PROMPT = <<~PROMPT
    Generate a short Japanese conversation exercise for a learner at JLPT %s level.

    Context: %s
    %s

    ## Roles — STRICT RULE

    The learner always plays the CUSTOMER / GUEST / VISITOR role.
    The other speaker (REQUESTER) is always staff, a service worker, or a service provider.

    NEVER generate a card where the learner must play a staff, waiter, shop clerk, receptionist,
    or any service role. The learner is always the one being served.

    Examples:
    - Restaurant: requester = waiter → learner responds as customer ordering or answering
    - Hotel: requester = front desk staff → learner responds as guest checking in
    - Shop: requester = shop clerk → learner responds as shopper
    - Train station: requester = station staff → learner responds as traveller

    The exercise card drills the learner's response. They see what is said TO them and must produce their reply.

    ## Output

    Respond with JSON only — no markdown, no explanation.
    {
      "request_jp": "<what is said TO the learner — in Japanese, short and natural>",
      "request_en": "<natural English translation of the request>",
      "request_reading": "<hiragana-only reading of request_jp — every character written in hiragana, no kanji or katakana>",
      "response_jp": "<what the learner (the layman/responder) should say back — in Japanese, short and natural, polite ます/です form>",
      "response_en": "<natural English translation of the response>",
      "response_reading": "<hiragana-only reading of response_jp — every character written in hiragana, no kanji or katakana>",
      "notes": "<optional brief English notes about grammar, vocabulary, or cultural context — null if not needed>"
    }

    Keep both lines to 1-2 sentences. Use kanji appropriate for the JLPT level.
  PROMPT

  IMPROVE_PROMPT = <<~PROMPT
    You are improving an existing Japanese conversation exercise card based on learner feedback.

    ## Current card

    Request (JP):  %s
    Request (EN):  %s
    Response (JP): %s
    Response (EN): %s
    Difficulty:    JLPT %s
    Context:       %s

    ## Feedback from the learner

    %s

    ## Task

    Rewrite the card to address the feedback. Keep the same JLPT level and context.
    The learner always plays the CUSTOMER / GUEST / VISITOR — never staff or a service role.

    ## Output

    Respond with JSON only — no markdown, no explanation.
    {
      "request_jp": "<revised request in Japanese>",
      "request_en": "<natural English translation>",
      "request_reading": "<hiragana-only reading of request_jp>",
      "response_jp": "<revised response in Japanese, polite ます/です form>",
      "response_en": "<natural English translation>",
      "response_reading": "<hiragana-only reading of response_jp>",
      "notes": "<optional brief English notes — null if not needed>"
    }
  PROMPT

  READINGS_PROMPT = <<~PROMPT
    Convert each Japanese sentence to a hiragana-only reading (no kanji, no katakana).

    Request:  %s
    Response: %s

    Respond with JSON only — no markdown, no explanation.
    {
      "request_reading":  "<hiragana-only reading of the request>",
      "response_reading": "<hiragana-only reading of the response>"
    }
  PROMPT

  def self.call(context_name:, difficulty:, prompt: nil)
    new(context_name: context_name, difficulty: difficulty, prompt: prompt).call
  end

  def self.improve(exercise:, feedbacks:)
    new(context_name: nil, difficulty: exercise.difficulty_level).improve(exercise, feedbacks)
  end

  def self.readings_for(exercise:)
    new(context_name: nil, difficulty: nil).fetch_readings(exercise)
  end

  def initialize(context_name:, difficulty:, prompt: nil)
    @context_name = context_name
    @difficulty   = difficulty
    @prompt       = prompt
  end

  def call
    stdout, stderr = run_psi(build_prompt)
    parse_result(stdout, stderr)
  end

  def fetch_readings(exercise)
    prompt = format(READINGS_PROMPT, exercise.request_jp, exercise.response_jp)
    stdout, stderr = run_psi(prompt)
    lines = stdout.lines.map { |l| JSON.parse(l.strip) rescue nil }.compact
    raise "psi error: #{lines.find { |l| l["type"] == "error" }&.dig("message")}" if lines.any? { |l| l["type"] == "error" }
    response = lines.find { |l| l["type"] == "response" }
    raise "psi failed: #{stderr.lines.first&.strip || "no response"}" unless response
    data = JSON.parse(response["content"].strip.gsub(/\A```(?:json)?\n?/, "").gsub(/\n?```\z/, ""))
    {
      request_reading:  data["request_reading"].to_s.strip.presence,
      response_reading: data["response_reading"].to_s.strip.presence
    }
  rescue JSON::ParserError => e
    raise "unexpected LLM response format: #{e.message}"
  end

  def improve(exercise, feedbacks)
    feedback_text = feedbacks.map.with_index(1) { |f, i| "#{i}. #{f.body}" }.join("\n")
    full_prompt = format(
      IMPROVE_PROMPT,
      exercise.request_jp, exercise.request_en,
      exercise.response_jp, exercise.response_en,
      exercise.difficulty_level.upcase,
      exercise.context&.name || "general",
      feedback_text
    )
    stdout, stderr = run_psi(full_prompt)
    parse_result(stdout, stderr)
  end

  private

  def parse_result(stdout, stderr)
    lines = stdout.lines.map { |l| JSON.parse(l.strip) rescue nil }.compact

    if (err = lines.find { |l| l["type"] == "error" })
      raise "psi error: #{err["message"]}"
    end

    response = lines.find { |l| l["type"] == "response" }
    raise "psi failed: #{stderr.lines.first&.strip || "no response"}" unless response

    data = JSON.parse(response["content"].strip.gsub(/\A```(?:json)?\n?/, "").gsub(/\n?```\z/, ""))
    Result.new(
      request_jp:       data["request_jp"].to_s.strip,
      request_en:       data["request_en"].to_s.strip,
      request_reading:  data["request_reading"].to_s.strip.presence,
      response_jp:      data["response_jp"].to_s.strip,
      response_en:      data["response_en"].to_s.strip,
      response_reading: data["response_reading"].to_s.strip.presence,
      notes:            data["notes"].presence
    )
  rescue JSON::ParserError => e
    raise "unexpected LLM response format: #{e.message}"
  end

  def build_prompt
    extra = @prompt.present? ? "Additional instructions: #{@prompt}" : ""
    format(PROMPT, @difficulty.upcase, @context_name, extra)
  end

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
