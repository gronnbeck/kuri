# frozen_string_literal: true

class ConversationPartner
  include PsiCallable

  Result = Struct.new(:feedback, :correct, :next_line_jp, :next_line_en, :next_line_furigana, :scenario_complete, :hints, keyword_init: true)

  PROMPT = <<~PROMPT
    You are roleplaying as a Japanese %s staff member in a short conversation with a beginner Japanese learner.

    Scenario: %s

    Conversation so far:
    %s

    %s

    Respond with JSON only — no markdown, no explanation.
    {
      "feedback": "<brief English feedback on the learner's Japanese, or null if this is the opening line>",
      "correct": <true if their response was understandable/appropriate, false if not, null for opening>,
      "next_line_jp": "<your next natural Japanese line — short, polite ます/です form, beginner-friendly>",
      "next_line_en": "<English translation of your line>",
      "next_line_furigana": "<hiragana reading of your line>",
      "scenario_complete": <true only when the interaction has naturally concluded, e.g. customer has left>,
      "hints": [
        { "jp": "<a Japanese phrase the learner could use to respond>", "en": "<English meaning>" },
        { "jp": "<another option>", "en": "<English meaning>" }
      ]
    }

    Keep your lines to 1-2 sentences. Hints should be 2-3 natural responses the learner could give to your next line.
  PROMPT

  def self.call(theme_name:, scenario:, history:, user_input: nil)
    new(theme_name: theme_name, scenario: scenario, history: history, user_input: user_input).call
  end

  def initialize(theme_name:, scenario:, history:, user_input: nil)
    @theme_name = theme_name
    @scenario   = scenario
    @history    = history
    @user_input = user_input
  end

  def call
    prompt = build_prompt
    stdout, stderr = run_psi(prompt)

    lines = stdout.lines.map { |l| JSON.parse(l.strip) rescue nil }.compact

    if (err = lines.find { |l| l["type"] == "error" })
      raise "psi error: #{err["message"]}"
    end

    response = lines.find { |l| l["type"] == "response" }
    raise "psi failed: #{stderr.lines.first&.strip || "no response"}" unless response

    data = JSON.parse(response["content"].strip.gsub(/\A```(?:json)?\n?/, "").gsub(/\n?```\z/, ""))
    Result.new(
      feedback:           data["feedback"],
      correct:            data["correct"],
      next_line_jp:       data["next_line_jp"].to_s.strip,
      next_line_en:       data["next_line_en"].to_s.strip,
      next_line_furigana: data["next_line_furigana"].to_s.strip,
      scenario_complete:  data["scenario_complete"] == true,
      hints:              Array(data["hints"])
    )
  rescue JSON::ParserError => e
    raise "unexpected LLM response format: #{e.message}"
  end

  protected

  def run_psi(prompt)
    Bundler.with_unbundled_env do
      stdout, stderr, _status = Open3.capture3(psi_env, PSI_BIN, "--pp", *PSI_NO_TOOLS_FLAGS, stdin_data: prompt)
      [ stdout, stderr ]
    end
  rescue Errno::ENOENT
    raise "psi not found at #{PSI_BIN}. Set PSI_BIN env var."
  end

  private

  def build_prompt
    history_text = if @history.empty?
      "(start of conversation)"
    else
      @history.map do |turn|
        if turn["role"] == "staff"
          "Staff: #{turn["jp"]} (#{turn["en"]})"
        else
          "Learner: #{turn["jp"]}"
        end
      end.join("\n")
    end

    instruction = if @user_input
      "The learner just said: \"#{@user_input}\"\nEvaluate their response and generate your next line."
    else
      "Generate your opening line to start the scenario. Set feedback and correct to null."
    end

    format(PROMPT, @theme_name.downcase, @scenario, history_text, instruction)
  end
end
