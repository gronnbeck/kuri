# frozen_string_literal: true

class UsefulPhraseChecker
  include PsiCallable

  Result = Struct.new(:correct, :feedback, keyword_init: true)

  PRODUCING_PROMPT = <<~PROMPT
    You are a Japanese language teacher evaluating a beginner student's answer.

    Context: %s
    The student was given this English phrase: "%s"
    They were asked to write it in Japanese.
    The student wrote: %s

    The expected Japanese is: "%s"

    Accept reasonable variations in wording or politeness level as long as the meaning is correct.

    Respond on exactly two lines:
    Line 1: CORRECT or INCORRECT
    Line 2: One short, encouraging sentence of feedback in English.
  PROMPT

  CONSUMING_PROMPT = <<~PROMPT
    You are a Japanese language teacher evaluating a beginner student's answer.

    Context: %s
    The student was shown this Japanese phrase: "%s"
    They were asked to translate it into English.
    The student wrote: %s

    The expected English meaning is: "%s"

    Accept reasonable paraphrases — the core meaning just needs to be captured correctly.

    Respond on exactly two lines:
    Line 1: CORRECT or INCORRECT
    Line 2: One short, encouraging sentence of feedback in English.
  PROMPT

  def self.call(mode:, context:, phrase_jp:, phrase_en:, answer:)
    new(mode: mode, context: context, phrase_jp: phrase_jp, phrase_en: phrase_en, answer: answer).call
  end

  def initialize(mode:, context:, phrase_jp:, phrase_en:, answer:)
    @mode      = mode
    @context   = context
    @phrase_jp = phrase_jp
    @phrase_en = phrase_en
    @answer    = answer
  end

  def call
    prompt = if @mode == "producing"
      format(PRODUCING_PROMPT, @context, @phrase_en, @answer, @phrase_jp)
    else
      format(CONSUMING_PROMPT, @context, @phrase_jp, @answer, @phrase_en)
    end

    stdout, stderr = run_psi(prompt)
    lines = stdout.lines.map { |l| JSON.parse(l.strip) rescue nil }.compact

    if (err = lines.find { |l| l["type"] == "error" })
      raise "psi error: #{err["message"]}"
    end

    response = lines.find { |l| l["type"] == "response" }
    raise "psi failed: #{stderr.lines.first&.strip || "no response"}" unless response

    content = response["content"].strip
    verdict, *rest = content.lines
    Result.new(
      correct:  verdict.strip.upcase.start_with?("CORRECT"),
      feedback: rest.join.strip
    )
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
end
