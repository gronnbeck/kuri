# frozen_string_literal: true

require "test_helper"

class SentencePatternCheckerTest < ActiveSupport::TestCase
  DEFAULT_ARGS = {
    english: "I drink tea.",
    pattern: "X を飲みます",
    answer: "私はお茶を飲みます。"
  }.freeze

  # Subclass that injects a fake psi response without spawning a process.
  class FakeChecker < SentencePatternChecker
    def initialize(psi_output:, **args)
      super(**args)
      @psi_output = psi_output
    end

    protected

    def run_psi(_prompt)
      @psi_output
    end
  end

  def psi_output(content)
    [ { "type" => "response", "content" => content }.to_json + "\n", "" ]
  end

  def checker(psi_content:, **overrides)
    FakeChecker.new(psi_output: psi_output(psi_content), **DEFAULT_ARGS.merge(overrides))
  end

  test "returns correct result when LLM says CORRECT" do
    result = checker(psi_content: "CORRECT\nGreat job! Your sentence is perfect.").call
    assert result.correct
    assert_equal "Great job! Your sentence is perfect.", result.feedback
  end

  test "returns incorrect result when LLM says INCORRECT" do
    result = checker(psi_content: "INCORRECT\nTry using を before 飲みます.").call
    assert_not result.correct
    assert_equal "Try using を before 飲みます.", result.feedback
  end

  test "tolerates CORRECT with trailing whitespace" do
    result = checker(psi_content: "CORRECT  \nNice work!").call
    assert result.correct
    assert_equal "Nice work!", result.feedback
  end

  test "raises when psi binary is missing" do
    c = SentencePatternChecker.new(**DEFAULT_ARGS)
    # Override run_psi to simulate missing binary
    def c.run_psi(_)
      raise RuntimeError, "psi not found at /fake/psi. Set PSI_BIN env var."
    end

    error = assert_raises(RuntimeError) { c.call }
    assert_match(/psi not found/, error.message)
  end

  test "raises when psi returns an error event" do
    error_output = [ { "type" => "error", "message" => "API key missing" }.to_json + "\n", "" ]
    c = FakeChecker.new(psi_output: error_output, **DEFAULT_ARGS)
    error = assert_raises(RuntimeError) { c.call }
    assert_match(/psi error/, error.message)
  end

  test "raises when psi returns no response event" do
    c = FakeChecker.new(psi_output: [ "", "unexpected crash\n" ], **DEFAULT_ARGS)
    error = assert_raises(RuntimeError) { c.call }
    assert_match(/psi failed/, error.message)
  end
end
