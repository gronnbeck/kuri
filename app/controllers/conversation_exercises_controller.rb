# frozen_string_literal: true

class ConversationExercisesController < ApplicationController
  before_action :set_exercise, only: [ :show, :edit, :update, :destroy, :add_to_anki, :generate_audio ]

  def index
    @exercises = ConversationExercise.includes(:context).order(created_at: :desc)
    render Views::ConversationExercises::Index.new(exercises: @exercises)
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

    context_name = context&.name || params[:context_name].presence || "general"
    result = ConversationExerciseGenerator.call(
      context_name: context_name,
      difficulty:   difficulty,
      prompt:       prompt
    )

    @exercise = ConversationExercise.create!(
      context:          context,
      request_jp:       result.request_jp,
      request_en:       result.request_en,
      response_jp:      result.response_jp,
      response_en:      result.response_en,
      notes:            result.notes,
      difficulty_level: difficulty
    )
    redirect_to conversation_exercise_path(@exercise)
  rescue => e
    redirect_to new_conversation_exercise_path, alert: "Generation failed: #{e.message}"
  end

  def show
    render Views::ConversationExercises::Show.new(exercise: @exercise)
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
    kind   = params[:kind].to_s
    actor  = Actor.order(:created_at).first
    unless actor
      redirect_to conversation_exercise_path(@exercise), alert: "Add an actor in Settings → Listen → Actors first."
      return
    end

    text = kind == "request" ? @exercise.request_jp : @exercise.response_jp
    ca   = @exercise.conversation_audios.find_or_initialize_by(kind: kind)
    ca.save! unless ca.persisted?

    audio_data = ElevenLabsTts.call(text, voice_id: actor.voice_id)
    ca.audio.attach(
      io:           StringIO.new(audio_data),
      filename:     "conv_#{@exercise.id}_#{kind}.mp3",
      content_type: "audio/mpeg"
    )
    redirect_to conversation_exercise_path(@exercise), notice: "#{kind.capitalize} audio generated."
  rescue => e
    redirect_to conversation_exercise_path(@exercise), alert: "Audio generation failed: #{e.message}"
  end

  def add_to_anki
    setting = AnkiConversationSetting.current
    unless setting.persisted? && setting.deck_name.present? && setting.note_type.present?
      redirect_to conversation_exercise_path(@exercise), alert: "Configure Anki settings first."
      return
    end

    exporter = AnkiConnect::ConversationExporter.new(setting)
    exporter.export(@exercise)
    redirect_to conversation_exercise_path(@exercise), notice: "Added to Anki."
  rescue => e
    redirect_to conversation_exercise_path(@exercise), alert: "Anki export failed: #{e.message}"
  end

  private

  def set_exercise
    @exercise = ConversationExercise.find(params[:id])
  end

  def exercise_params
    params.expect(conversation_exercise: [ :context_id, :request_jp, :request_en, :response_jp, :response_en, :notes, :difficulty_level ])
  end
end
