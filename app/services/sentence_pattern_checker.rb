# frozen_string_literal: true

class SentencePatternChecker
  include PsiCallable

  Result = Struct.new(:correct, :feedback, keyword_init: true)

  PROMPT = <<~PROMPT
    You are a Japanese language teacher evaluating a beginner student's answer.

    The student was asked to write a Japanese sentence that:
    - Translates this English sentence: %s
    - Uses this grammar pattern: %s

    The student wrote: %s

    Evaluate the answer. Accept reasonable variations — minor differences in vocabulary or politeness level are fine as long as the meaning is correct and the pattern is used.

    Respond on exactly two lines:
    Line 1: CORRECT or INCORRECT
    Line 2: One short, encouraging sentence of feedback in English.
  PROMPT

  def self.call(english:, pattern:, answer:)
    new(english: english, pattern: pattern, answer: answer).call
  end

  def initialize(english:, pattern:, answer:)
    @english = english
    @pattern = pattern
    @answer = answer
  end

  def call
    prompt = format(PROMPT, @english, @pattern, @answer)
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
      correct: verdict.strip.upcase.start_with?("CORRECT"),
      feedback: rest.join.strip
    )
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
