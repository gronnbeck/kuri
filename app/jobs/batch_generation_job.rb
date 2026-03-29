# frozen_string_literal: true

class BatchGenerationJob < ApplicationJob
  queue_as :default

  MAX_ATTEMPTS = 3

  # Covers a wide range of everyday scenarios to keep batch cards varied.
  CONVERSATION_SCENARIOS = [
    "at a clothing shop — the clerk asks about size or style preference",
    "at a convenience store — the cashier asks about a loyalty card or bag",
    "at a pharmacy — the pharmacist asks about symptoms or prescription pickup",
    "at a train station — the staff member asks about destination or ticket type",
    "at a hotel — the front desk asks about check-in details or room preferences",
    "at a hair salon — the stylist asks what kind of cut or treatment the customer wants",
    "at a bookshop — the staff asks if the customer needs help finding something",
    "at a post office — the clerk asks about the contents or destination of a parcel",
    "at a bank — the teller asks the customer to confirm account details",
    "at a doctor's clinic — the receptionist or nurse asks about the reason for the visit",
    "at a dentist — the receptionist confirms the appointment details",
    "at a gym — the staff explains a membership option and asks if the customer is interested",
    "at a tourist information desk — the staff asks where the visitor is heading",
    "on a bus or taxi — the driver asks about the destination or stop",
    "at a school office — the staff asks about enrollment or schedule",
    "at a café — the barista confirms the drink order or asks about size",
    "at a library — the librarian asks if the patron needs help or has a reservation",
    "at an electronics store — the staff asks what kind of device the customer needs",
    "at a supermarket service desk — the clerk asks about a refund or exchange",
    "at a city hall — the clerk asks what kind of procedure the visitor needs"
  ].freeze

  def perform(batch_id)
    batch = Batch.find(batch_id)
    batch.update!(status: :running)

    # Diversity tracking — shuffled scenario list for conversations;
    # accumulated verb list for exclusion in verb batches.
    scenarios     = CONVERSATION_SCENARIOS.shuffle
    used_verbs    = []

    batch.batch_items.order(:id).each_with_index do |item, index|
      scenario = scenarios[index % scenarios.size]
      generate_item(batch, item, scenario: scenario, used_verbs: used_verbs)
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

  def generate_item(batch, item, scenario:, used_verbs:)
    last_error = nil

    MAX_ATTEMPTS.times do
      item.increment!(:attempt_count)
      begin
        exercise = if batch.conversation?
          generate_conversation(batch, scenario: scenario)
        else
          generate_verb(batch, used_verbs: used_verbs)
        end
        item.update!(status: :completed, exercise: exercise)
        batch.increment!(:completed_count)
        used_verbs << exercise.verb_jp if exercise.respond_to?(:verb_jp)
        return
      rescue => e
        last_error = e
      end
    end

    item.update!(status: :failed, error_message: last_error&.message)
    batch.increment!(:failed_count)
  end

  def generate_conversation(batch, scenario:)
    result = ConversationExerciseGenerator.call(
      context_name: batch.context&.name || "general",
      difficulty:   batch.difficulty,
      scenario:     scenario
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

  def generate_verb(batch, used_verbs:)
    target_form = batch.target_form.presence ||
                  VerbTransformationExercise::TARGET_FORMS.sample

    result = VerbTransformationExerciseGenerator.call(
      difficulty:    batch.difficulty,
      target_form:   target_form,
      exclude_verbs: used_verbs
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
