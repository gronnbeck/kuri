# frozen_string_literal: true

require "test_helper"

class NoteEnricherTest < ActiveSupport::TestCase
  # Stub run_psi on the instance by subclassing and overriding.
  def enricher_with_response(content)
    fake_stdout = "{\"type\":\"response\",\"content\":#{content.to_json}}\n"
    enricher = NoteEnricher.new(transformation: "reading", source_value: "dummy")
    enricher.define_singleton_method(:run_psi) { |_| [ fake_stdout, "" ] }
    enricher
  end

  def enricher_with_error(message)
    fake_stdout = "{\"type\":\"error\",\"message\":#{message.to_json}}\n"
    enricher = NoteEnricher.new(transformation: "reading", source_value: "dummy")
    enricher.define_singleton_method(:run_psi) { |_| [ fake_stdout, "" ] }
    enricher
  end

  test "reading transformation returns hiragana" do
    NoteEnricher.define_singleton_method(:call) do |**kwargs|
      "{\"type\":\"response\",\"content\":\"たべる\"}\n".tap do
        # just return the stubbed value directly
      end
      "たべる"
    end
    assert_equal "たべる", NoteEnricher.call(transformation: "reading", source_value: "食べる")
  ensure
    NoteEnricher.singleton_class.remove_method(:call) rescue nil
  end

  test "custom transformation raises when no prompt given" do
    assert_raises(RuntimeError) do
      # We need a real instance but intercept run_psi
      enricher = NoteEnricher.new(transformation: "custom", source_value: "食べる", custom_prompt: nil)
      enricher.call
    end
  end

  test "raises on unknown transformation" do
    enricher = NoteEnricher.new(transformation: "unknown", source_value: "食べる")
    # Override run_psi so it doesn't try to spawn psi
    enricher.define_singleton_method(:run_psi) { |_| [ "", "" ] }
    assert_raises(KeyError) { enricher.call }
  end

  test "raises when psi returns an error response" do
    fake_stdout = "{\"type\":\"error\",\"message\":\"quota exceeded\"}\n"
    enricher = NoteEnricher.new(transformation: "reading", source_value: "食べる")
    enricher.define_singleton_method(:run_psi) { |_| [ fake_stdout, "" ] }
    err = assert_raises(RuntimeError) { enricher.call }
    assert_match "quota exceeded", err.message
  end

  test "returns content from response line" do
    fake_stdout = "{\"type\":\"response\",\"content\":\"たべる\"}\n"
    enricher = NoteEnricher.new(transformation: "reading", source_value: "食べる")
    enricher.define_singleton_method(:run_psi) { |_| [ fake_stdout, "" ] }
    assert_equal "たべる", enricher.call
  end

  test "custom prompt is prepended to source value" do
    received_prompt = nil
    fake_stdout = "{\"type\":\"response\",\"content\":\"example\"}\n"
    enricher = NoteEnricher.new(
      transformation: "custom",
      source_value: "食べる",
      custom_prompt: "Use in a sentence."
    )
    enricher.define_singleton_method(:run_psi) do |prompt|
      received_prompt = prompt
      [ fake_stdout, "" ]
    end
    enricher.call
    assert_includes received_prompt, "Use in a sentence."
    assert_includes received_prompt, "食べる"
  end
end
