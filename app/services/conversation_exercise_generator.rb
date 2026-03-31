# frozen_string_literal: true

class ConversationExerciseGenerator
  PSI_BIN = ENV.fetch("PSI_BIN", "#{Dir.home}/.local/bin/psi")

  Result = Struct.new(:request_jp, :request_en, :request_reading, :response_jp, :response_en, :response_reading, :notes, :context_name, keyword_init: true)

  PROMPT = <<~PROMPT
    Generate a short Japanese conversation exercise for a learner at JLPT %s level.

    Context: %s
    Scenario: %s
    %s

    ## Roles — ABSOLUTE RULE

    The learner always plays the CUSTOMER / GUEST / PATIENT / PASSENGER / CIVILIAN role.
    The other speaker (the one asking or addressing the learner) is ALWAYS staff, a service worker,
    a professional, or someone in a helper role.

    NEVER generate a card where the learner's response sounds like:
    - A waiter or server taking an order
    - A shop clerk, cashier, or receptionist serving a customer
    - Any staff or service-role phrasing (いらっしゃいませ, ご注文はお決まりですか, etc.)

    The learner is always the one BEING served, helped, asked, or welcomed.
    The learner's response is always that of a layperson — a customer, guest, patient, or passenger.

    ## Output

    Respond with JSON only — no markdown, no explanation.
    {
      "context_name": "<short English label for this context, e.g. 'restaurant', 'pharmacy', 'train station'>",
      "request_jp": "<what is said TO the learner — in Japanese, short and natural>",
      "request_en": "<natural English translation of the request>",
      "request_reading": "<hiragana-only reading of request_jp — every character written in hiragana, no kanji or katakana>",
      "response_jp": "<what the learner says back — in Japanese, short and natural, polite ます/です form>",
      "response_en": "<natural English translation of the response>",
      "response_reading": "<hiragana-only reading of response_jp — every character written in hiragana, no kanji or katakana>",
      "notes": "<optional brief English notes about grammar, vocabulary, or cultural context — null if not needed>"
    }

    ## Avoid repetition

    Do NOT generate a card whose request is the same as or very similar to any of these
    already-generated requests:
    %s

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

  def self.call(context_name:, difficulty:, prompt: nil, scenario: nil, exclude_requests: [])
    new(context_name: context_name, difficulty: difficulty, prompt: prompt, scenario: scenario, exclude_requests: exclude_requests).call
  end

  def self.improve(exercise:, feedbacks:)
    new(context_name: nil, difficulty: exercise.difficulty_level).improve(exercise, feedbacks)
  end

  def self.readings_for(exercise:)
    new(context_name: nil, difficulty: nil).fetch_readings(exercise)
  end

  def initialize(context_name:, difficulty:, prompt: nil, scenario: nil, exclude_requests: [])
    @context_name      = context_name
    @difficulty        = difficulty
    @prompt            = prompt
    @scenario          = scenario
    @exclude_requests  = Array(exclude_requests)
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
    data = extract_json(response["content"])
    {
      request_reading:  data["request_reading"].to_s.strip.presence,
      response_reading: data["response_reading"].to_s.strip.presence
    }
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

    data = extract_json(response["content"])
    Result.new(
      context_name:     data["context_name"].to_s.strip.presence,
      request_jp:       data["request_jp"].to_s.strip,
      request_en:       data["request_en"].to_s.strip,
      request_reading:  data["request_reading"].to_s.strip.presence,
      response_jp:      data["response_jp"].to_s.strip,
      response_en:      data["response_en"].to_s.strip,
      response_reading: data["response_reading"].to_s.strip.presence,
      notes:            data["notes"].presence
    )
  end

  def build_prompt
    scenario = @scenario.presence || "any everyday situation — be creative and specific"
    extra    = @prompt.present? ? "Additional instructions: #{@prompt}" : ""
    exclude  = @exclude_requests.any? ? @exclude_requests.map.with_index(1) { |r, i| "#{i}. #{r}" }.join("\n") : "none"
    format(PROMPT, @difficulty.upcase, @context_name, scenario, extra, exclude)
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

  def extract_json(content)
    json = content.to_s.strip
    json = json.gsub(/\A```(?:json)?\n?/, "").gsub(/\n?```\z/, "").strip
    json = json[/\{.*\}/m] || json
    JSON.parse(json)
  rescue JSON::ParserError => e
    raise "unexpected LLM response format: #{e.message}"
  end
end
