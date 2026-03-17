# frozen_string_literal: true

require "test_helper"

class TranslationSentenceGeneratorTest < ActiveSupport::TestCase
  def psi_output(english:, japanese:)
    json = { "english" => english, "japanese" => japanese }.to_json
    [ { "type" => "response", "content" => json }.to_json + "\n", "" ]
  end

  class FakeGenerator < TranslationSentenceGenerator
    def initialize(outputs)
      @outputs = outputs.dup
    end

    def run_psi(_prompt)
      @outputs.shift || raise("no more outputs")
    end
  end

  test "creates and returns a new TranslationSentence" do
    gen = FakeGenerator.new([ psi_output(english: "I buy bread.", japanese: "私はパンを買います。") ])

    assert_difference "TranslationSentence.count", 1 do
      sentence = gen.call
      assert_equal "I buy bread.", sentence.english
      assert_equal "私はパンを買います。", sentence.japanese
    end
  end

  test "retries when the generated sentence already exists in the db" do
    TranslationSentence.create!(english: "i drink tea.", japanese: "お茶を飲みます。")

    gen = FakeGenerator.new([
      psi_output(english: "I drink tea.", japanese: "お茶を飲みます。"),  # duplicate
      psi_output(english: "I cook dinner.", japanese: "私は夕食を作ります。")  # unique
    ])

    assert_difference "TranslationSentence.count", 1 do
      sentence = gen.call
      assert_equal "I cook dinner.", sentence.english
    end
  end

  test "raises after MAX_RETRIES consecutive duplicates" do
    TranslationSentence.create!(english: "i eat rice.", japanese: "ご飯を食べます。")

    duplicate = psi_output(english: "I eat rice.", japanese: "ご飯を食べます。")
    gen = FakeGenerator.new(Array.new(TranslationSentenceGenerator::MAX_RETRIES, duplicate))

    assert_raises(RuntimeError, /unique sentence/) { gen.call }
  end

  test "strips markdown fences from response" do
    fenced = "```json\n{\"english\":\"I go home.\",\"japanese\":\"家に帰ります。\"}\n```"
    output = [ { "type" => "response", "content" => fenced }.to_json + "\n", "" ]

    gen = FakeGenerator.new([ output ])
    sentence = gen.call
    assert_equal "I go home.", sentence.english
  end

  test "raises on malformed JSON response" do
    bad = [ { "type" => "response", "content" => "not json" }.to_json + "\n", "" ]
    gen = FakeGenerator.new([ bad ])
    assert_raises(RuntimeError, /unexpected LLM response format/) { gen.call }
  end
end
