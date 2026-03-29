# frozen_string_literal: true

class BatchGenerationJob < ApplicationJob
  queue_as :default

  MAX_ATTEMPTS = 3

  def perform(batch_id)
    batch = Batch.find(batch_id)
    batch.update!(status: :running)

    batch.batch_items.order(:id).each do |item|
      generate_item(batch, item)
      ActionCable.server.broadcast(
        batch.stream_name,
        { type: "progress", completed: batch.completed_count,
          failed: batch.failed_count, total: batch.total }
      )
    end

    batch.update!(status: :completed)
    ActionCable.server.broadcast(batch.stream_name, { type: "done" })
  rescue => e
    batch&.update!(status: :failed)
    ActionCable.server.broadcast(batch.stream_name, { type: "done" })
    raise
  end

  private

  def generate_item(batch, item)
    last_error = nil

    MAX_ATTEMPTS.times do
      item.increment!(:attempt_count)
      begin
        exercise = batch.conversation? ? generate_conversation(batch) : generate_verb(batch)
        item.update!(status: :completed, exercise: exercise)
        batch.increment!(:completed_count)
        return
      rescue => e
        last_error = e
      end
    end

    item.update!(status: :failed, error_message: last_error&.message)
    batch.increment!(:failed_count)
  end

  def generate_conversation(batch)
    result = ConversationExerciseGenerator.call(
      context_name: batch.context&.name || "general",
      difficulty:   batch.difficulty
    )
    ConversationExercise.create!(
      context:          batch.context,
      request_jp:       result.request_jp,
      request_en:       result.request_en,
      request_reading:  result.request_reading,
      response_jp:      result.response_jp,
      response_en:      result.response_en,
      response_reading: result.response_reading,
      notes:            result.notes,
      difficulty_level: batch.difficulty
    )
  end

  def generate_verb(batch)
    target_form = batch.target_form.presence ||
                  VerbTransformationExercise::TARGET_FORMS.sample

    result = VerbTransformationExerciseGenerator.call(
      difficulty:  batch.difficulty,
      target_form: target_form
    )
    VerbTransformationExercise.create!(
      verb_jp:          result.verb_jp,
      verb_en:          result.verb_en,
      verb_reading:     result.verb_reading,
      target_form:      result.target_form,
      answer_jp:        result.answer_jp,
      answer_en:        result.answer_en,
      answer_reading:   result.answer_reading,
      notes:            result.notes,
      difficulty_level: result.difficulty_level.presence || batch.difficulty
    )
  end
end
