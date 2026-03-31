# frozen_string_literal: true

class ConversationExercisesController < ApplicationController
  before_action :set_exercise, only: [ :show, :edit, :update, :destroy, :add_to_anki, :generate_audio, :regenerate_audio, :confirm_audio, :discard_pending_audio, :archive, :improve, :generate_readings ]

  def index
    scope = params[:archived] == "1" ? ConversationExercise.where(archived: true) : ConversationExercise.where(archived: false)
    @exercises = scope.includes(:context).order(created_at: :desc)
    render Views::ConversationExercises::Index.new(exercises: @exercises, show_archived: params[:archived] == "1")
  end

  def new
    @contexts = Context.order(:name)
    render Views::ConversationExercises::New.new(contexts: @contexts, exercise: ConversationExercise.new)
  end

  def generate
    context_id = params[:context_id].presence
    context    = context_id ? Context.find(context_id) : nil
    difficulty = params[:difficulty].presence || "n5"
    prompt     = params[:prompt].presence

    context_name = context&.name || "general"
    result = ConversationExerciseGenerator.call(
      context_name: context_name,
      difficulty:   difficulty,
      scenario:     prompt
    )

    context ||= Context.find_or_create_by!(name: result.context_name) if result.context_name.present?

    @exercise = ConversationExercise.create!(
      context:          context,
      request_jp:       result.request_jp,
      request_en:       result.request_en,
      request_reading:  result.request_reading,
      response_jp:      result.response_jp,
      response_en:      result.response_en,
      response_reading: result.response_reading,
      notes:            result.notes,
      difficulty_level: difficulty
    )
    redirect_to conversation_exercise_path(@exercise)
  rescue => e
    redirect_to new_conversation_exercise_path, alert: "Generation failed: #{e.message}"
  end

  def show
    setting = AnkiConversationSetting.current
    anki_configured = setting.persisted? && setting.deck_name.present? && setting.note_type.present?
    render Views::ConversationExercises::Show.new(exercise: @exercise, anki_configured: anki_configured)
  end

  def edit
    @contexts = Context.order(:name)
    render Views::ConversationExercises::Edit.new(exercise: @exercise, contexts: @contexts)
  end

  def update
    if @exercise.update(exercise_params)
      redirect_to conversation_exercise_path(@exercise), notice: "Exercise updated."
    else
      @contexts = Context.order(:name)
      render Views::ConversationExercises::Edit.new(exercise: @exercise, contexts: @contexts), status: :unprocessable_entity
    end
  end

  def destroy
    @exercise.destroy
    redirect_to conversation_exercises_path, notice: "Exercise deleted."
  end

  def generate_audio
    kind = params[:kind].to_s

    # For conversations we try to use a different actor for the other side.
    other_kind  = kind == "request" ? "response" : "request"
    other_audio = @exercise.conversation_audios.find_by(kind: other_kind)
    actor = Actor.pick_random(exclude_id: other_audio&.actor_id)

    unless actor
      redirect_to conversation_exercise_path(@exercise), alert: "Add an actor in Settings → Listen → Actors first."
      return
    end

    text = if kind == "request"
      @exercise.request_reading.presence || @exercise.request_jp
    else
      @exercise.response_reading.presence || @exercise.response_jp
    end
    ca   = @exercise.conversation_audios.find_or_initialize_by(kind: kind)
    ca.actor = actor
    ca.save! unless ca.persisted?

    audio_data = ElevenLabsTts.call(text, voice_id: actor.voice_id)
    ca.audio.attach(
      io:           StringIO.new(audio_data),
      filename:     "conv_#{@exercise.id}_#{kind}.mp3",
      content_type: "audio/mpeg"
    )
    ca.update_columns(actor_id: actor.id)
    redirect_to conversation_exercise_path(@exercise), notice: "#{kind.capitalize} audio generated."
  rescue => e
    redirect_to conversation_exercise_path(@exercise), alert: "Audio generation failed: #{e.message}"
  end

  def regenerate_audio
    kind = params[:kind].to_s
    ca   = @exercise.conversation_audios.find_by!(kind: kind)

    other_kind  = kind == "request" ? "response" : "request"
    other_audio = @exercise.conversation_audios.find_by(kind: other_kind)
    actor = Actor.pick_random(exclude_id: other_audio&.actor_id)

    unless actor
      redirect_to conversation_exercise_path(@exercise), alert: "Add an actor in Settings → Listen → Actors first."
      return
    end

    text = kind == "request" \
      ? (@exercise.request_reading.presence || @exercise.request_jp)
      : (@exercise.response_reading.presence || @exercise.response_jp)

    audio_data = ElevenLabsTts.call(text, voice_id: actor.voice_id)
    ca.pending_audio.attach(
      io:           StringIO.new(audio_data),
      filename:     "conv_#{@exercise.id}_#{kind}_pending.mp3",
      content_type: "audio/mpeg"
    )
    redirect_to conversation_exercise_path(@exercise), notice: "New #{kind} audio generated — review and confirm below."
  rescue => e
    redirect_to conversation_exercise_path(@exercise), alert: "Regeneration failed: #{e.message}"
  end

  def confirm_audio
    kind = params[:kind].to_s
    ca   = @exercise.conversation_audios.find_by!(kind: kind)
    raise "No pending audio to confirm." unless ca.pending_audio.attached?

    ca.audio.attach(ca.pending_audio.blob)
    ca.pending_audio.purge
    redirect_to conversation_exercise_path(@exercise), notice: "#{kind.capitalize} audio replaced."
  rescue => e
    redirect_to conversation_exercise_path(@exercise), alert: "Failed: #{e.message}"
  end

  def discard_pending_audio
    kind = params[:kind].to_s
    ca   = @exercise.conversation_audios.find_by!(kind: kind)
    ca.pending_audio.purge
    redirect_to conversation_exercise_path(@exercise), notice: "New #{kind} audio discarded."
  end

  def archive
    @exercise.update!(archived: !@exercise.archived)
    label = @exercise.archived? ? "archived" : "restored"
    redirect_to conversation_exercises_path, notice: "Exercise #{label}."
  end

  def improve
    feedbacks = @exercise.conversation_feedbacks.order(:created_at)
    if feedbacks.empty?
      redirect_to conversation_exercise_path(@exercise), alert: "Add at least one feedback note before improving."
      return
    end

    result = ConversationExerciseGenerator.improve(exercise: @exercise, feedbacks: feedbacks)
    @exercise.update!(
      request_jp:       result.request_jp,
      request_en:       result.request_en,
      request_reading:  result.request_reading,
      response_jp:      result.response_jp,
      response_en:      result.response_en,
      response_reading: result.response_reading,
      notes:            result.notes,
      anki_status:      :not_added
    )
    redirect_to conversation_exercise_path(@exercise), notice: "Exercise improved."
  rescue => e
    redirect_to conversation_exercise_path(@exercise), alert: "Improvement failed: #{e.message}"
  end

  def generate_readings
    result = ConversationExerciseGenerator.readings_for(exercise: @exercise)
    @exercise.update!(request_reading: result[:request_reading], response_reading: result[:response_reading])
    redirect_to conversation_exercise_path(@exercise), notice: "Readings generated."
  rescue => e
    redirect_to conversation_exercise_path(@exercise), alert: "Reading generation failed: #{e.message}"
  end

  def add_to_anki
    setting = AnkiConversationSetting.current
    unless setting.persisted? && setting.deck_name.present? && setting.note_type.present?
      redirect_to conversation_exercise_path(@exercise), alert: "Configure Anki settings first."
      return
    end

    re_add = @exercise.added?
    exporter = AnkiConnect::ConversationExporter.new(setting)
    exporter.export(@exercise)
    redirect_to conversation_exercise_path(@exercise), notice: re_add ? "Re-added to Anki." : "Added to Anki."
  rescue => e
    redirect_to conversation_exercise_path(@exercise), alert: "Anki export failed: #{e.message}"
  end

  private

  def set_exercise
    @exercise = ConversationExercise.find(params[:id])
  end

  def exercise_params
    params.expect(conversation_exercise: [ :context_id, :request_jp, :request_en, :request_reading, :response_jp, :response_en, :response_reading, :notes, :difficulty_level ])
  end
end
