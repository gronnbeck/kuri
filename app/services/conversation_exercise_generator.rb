# frozen_string_literal: true

class ConversationExerciseGenerator
  PSI_BIN = ENV.fetch("PSI_BIN", "#{Dir.home}/.local/bin/psi")

  Result = Struct.new(:request_jp, :request_en, :response_jp, :response_en, :notes, keyword_init: true)

  PROMPT = <<~PROMPT
    Generate a short Japanese conversation exercise for a learner at JLPT %s level.

    Context: %s
    %s

    ## Roles

    The RESPONDER is always a layman — an ordinary person with no special role (e.g. a customer, a guest, a passerby).
    The REQUESTER can be anyone appropriate for the context: staff, another customer, a friend, a stranger, etc.

    For example:
    - Restaurant: requester = waiter/staff, responder = customer
    - Talking to another customer in a restaurant: requester = customer, responder = customer
    - Hotel: requester = front desk staff, responder = guest
    - Train station: requester = station staff or another traveller, responder = traveller

    The exercise card will be used to drill the RESPONDER's line. The learner sees the request and must produce the response.

    ## Output

    Respond with JSON only — no markdown, no explanation.
    {
      "request_jp": "<what is said TO the learner — in Japanese, short and natural>",
      "request_en": "<natural English translation of the request>",
      "response_jp": "<what the learner (the layman/responder) should say back — in Japanese, short and natural, polite ます/です form>",
      "response_en": "<natural English translation of the response>",
      "notes": "<optional brief English notes about grammar, vocabulary, or cultural context — null if not needed>"
    }

    Keep both lines to 1-2 sentences. Use kanji appropriate for the JLPT level.
  PROMPT

  def self.call(context_name:, difficulty:, prompt: nil)
    new(context_name: context_name, difficulty: difficulty, prompt: prompt).call
  end

  def initialize(context_name:, difficulty:, prompt: nil)
    @context_name = context_name
    @difficulty   = difficulty
    @prompt       = prompt
  end

  def call
    full_prompt = build_prompt
    stdout, stderr = run_psi(full_prompt)

    lines = stdout.lines.map { |l| JSON.parse(l.strip) rescue nil }.compact

    if (err = lines.find { |l| l["type"] == "error" })
      raise "psi error: #{err["message"]}"
    end

    response = lines.find { |l| l["type"] == "response" }
    raise "psi failed: #{stderr.lines.first&.strip || "no response"}" unless response

    data = JSON.parse(response["content"].strip.gsub(/\A```(?:json)?\n?/, "").gsub(/\n?```\z/, ""))
    Result.new(
      request_jp:  data["request_jp"].to_s.strip,
      request_en:  data["request_en"].to_s.strip,
      response_jp: data["response_jp"].to_s.strip,
      response_en: data["response_en"].to_s.strip,
      notes:       data["notes"].presence
    )
  rescue JSON::ParserError => e
    raise "unexpected LLM response format: #{e.message}"
  end

  private

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
