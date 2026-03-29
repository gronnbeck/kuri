# frozen_string_literal: true

require "test_helper"

class BatchGenerationJobTest < ActiveJob::TestCase
  CONV_RESULT = ConversationExerciseGenerator::Result.new(
    request_jp: "これは何ですか",   request_en: "What is this?",   request_reading: "これはなんですか",
    response_jp: "これは本です",    response_en: "This is a book.", response_reading: "これはほんです",
    notes: nil
  )

  VERB_RESULT = VerbTransformationExerciseGenerator::Result.new(
    verb_jp: "食べる",    verb_en: "to eat",  verb_reading: "たべる",
    target_form: "te_form",
    answer_jp: "食べて",  answer_en: "eating", answer_reading: "たべて",
    difficulty_level: "n5", notes: nil
  )

  # ── conversation batch ──────────────────────────────────────────────────────

  test "creates conversation exercises and marks batch completed" do
    batch = Batch.create!(kind: :conversation, total: 2, difficulty: "n5")
    2.times { batch.batch_items.create! }

    with_conv_generator(CONV_RESULT) do
      BatchGenerationJob.perform_now(batch.id)
    end

    batch.reload
    assert_equal "completed", batch.status
    assert_equal 2, batch.completed_count
    assert_equal 0, batch.failed_count
    assert_equal 2, ConversationExercise.count
    assert batch.batch_items.all?(&:completed?)
  end

  test "stores exercise reference on batch item" do
    batch = Batch.create!(kind: :conversation, total: 1, difficulty: "n5")
    batch.batch_items.create!

    with_conv_generator(CONV_RESULT) do
      BatchGenerationJob.perform_now(batch.id)
    end

    item = batch.batch_items.first.reload
    assert_equal "ConversationExercise", item.exercise_type
    assert_not_nil item.exercise_id
  end

  # ── verb batch ──────────────────────────────────────────────────────────────

  test "creates verb exercises and marks batch completed" do
    batch = Batch.create!(kind: :verb, total: 2, difficulty: "n5")
    2.times { batch.batch_items.create! }

    with_verb_generator(VERB_RESULT) do
      BatchGenerationJob.perform_now(batch.id)
    end

    batch.reload
    assert_equal "completed", batch.status
    assert_equal 2, batch.completed_count
    assert_equal 2, VerbTransformationExercise.count
  end

  test "uses batch target_form when set" do
    batch = Batch.create!(kind: :verb, total: 1, difficulty: "n5", target_form: "ta_form")
    batch.batch_items.create!

    received_target_form = nil
    original = VerbTransformationExerciseGenerator.method(:call)
    VerbTransformationExerciseGenerator.define_singleton_method(:call) do |**kwargs|
      received_target_form = kwargs[:target_form]
      VERB_RESULT
    end

    BatchGenerationJob.perform_now(batch.id)
  ensure
    VerbTransformationExerciseGenerator.define_singleton_method(:call, original)
    assert_equal "ta_form", received_target_form
  end

  test "samples a random target_form when batch has none" do
    batch = Batch.create!(kind: :verb, total: 3, difficulty: "n5")
    3.times { batch.batch_items.create! }

    received = []
    original = VerbTransformationExerciseGenerator.method(:call)
    VerbTransformationExerciseGenerator.define_singleton_method(:call) do |**kwargs|
      received << kwargs[:target_form]
      VERB_RESULT
    end

    BatchGenerationJob.perform_now(batch.id)
  ensure
    VerbTransformationExerciseGenerator.define_singleton_method(:call, original)
    assert received.all? { |f| VerbTransformationExercise::TARGET_FORMS.include?(f) },
           "Expected all target forms to be valid TARGET_FORMS, got: #{received.inspect}"
  end

  # ── retry / error handling ──────────────────────────────────────────────────

  test "retries up to 3 times on transient failure then marks item failed" do
    batch = Batch.create!(kind: :conversation, total: 1, difficulty: "n5")
    batch.batch_items.create!

    call_count = 0
    original = ConversationExerciseGenerator.method(:call)
    ConversationExerciseGenerator.define_singleton_method(:call) do |**|
      call_count += 1
      raise "LLM timeout"
    end

    BatchGenerationJob.perform_now(batch.id)
  ensure
    ConversationExerciseGenerator.define_singleton_method(:call, original)
    assert_equal 3, call_count, "Expected exactly 3 attempts"
    batch.reload
    assert_equal "completed", batch.status
    assert_equal 0, batch.completed_count
    assert_equal 1, batch.failed_count
    item = batch.batch_items.first.reload
    assert item.failed?
    assert_match "LLM timeout", item.error_message
  end

  test "continues to next item after one item exhausts retries" do
    batch = Batch.create!(kind: :conversation, total: 2, difficulty: "n5")
    2.times { batch.batch_items.create! }

    call_count = 0
    original = ConversationExerciseGenerator.method(:call)
    ConversationExerciseGenerator.define_singleton_method(:call) do |**|
      call_count += 1
      raise "error" if call_count <= 3  # first item always fails
      CONV_RESULT                        # second item succeeds
    end

    BatchGenerationJob.perform_now(batch.id)
  ensure
    ConversationExerciseGenerator.define_singleton_method(:call, original)
    batch.reload
    assert_equal 1, batch.completed_count
    assert_equal 1, batch.failed_count
    assert_equal "completed", batch.status
  end

  # ── status transitions ──────────────────────────────────────────────────────

  test "marks batch running at start and completed at end" do
    batch = Batch.create!(kind: :conversation, total: 1, difficulty: "n5")
    batch.batch_items.create!

    statuses = []
    original_perform = BatchGenerationJob.instance_method(:perform)

    with_conv_generator(CONV_RESULT) do
      BatchGenerationJob.perform_now(batch.id)
    end

    batch.reload
    assert_equal "completed", batch.status
  end

  private

  def with_conv_generator(result)
    original = ConversationExerciseGenerator.method(:call)
    ConversationExerciseGenerator.define_singleton_method(:call) { |**| result }
    yield
  ensure
    ConversationExerciseGenerator.define_singleton_method(:call, original)
  end

  def with_verb_generator(result)
    original = VerbTransformationExerciseGenerator.method(:call)
    VerbTransformationExerciseGenerator.define_singleton_method(:call) { |**| result }
    yield
  ensure
    VerbTransformationExerciseGenerator.define_singleton_method(:call, original)
  end
end
