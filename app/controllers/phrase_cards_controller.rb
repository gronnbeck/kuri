# frozen_string_literal: true

class PhraseCardsController < ApplicationController
  before_action :set_card, only: [ :show, :edit, :update, :destroy, :generate_audio, :add_to_anki, :archive, :audio ]

  def index
    scope = params[:archived] == "1" ? PhraseCard.where(archived: true) : PhraseCard.where(archived: false)
    scope = scope.where(difficulty_level: params[:difficulty]) if params[:difficulty].present?
    direction = params[:sort] == "desc" ? :desc : :asc
    scope = scope.order(created_at: direction)
    @pagy, @cards = pagy(scope, items: 50)
    render Views::PhraseCards::Index.new(
      cards: @cards,
      pagy: @pagy,
      show_archived: params[:archived] == "1",
      difficulty: params[:difficulty],
      sort: direction.to_s
    )
  end

  def new
    render Views::PhraseCards::New.new(card: PhraseCard.new)
  end

  def generate
    prompt     = params[:prompt].to_s.strip
    english    = params[:english].to_s.strip
    difficulty = params[:difficulty].presence || "n5"

    if prompt.blank? && english.blank?
      redirect_to new_phrase_card_path, alert: "Enter a prompt or an English phrase."
      return
    end

    result = PhraseCardGenerator.call(prompt: prompt, english: english, difficulty: difficulty)

    @card = PhraseCard.create!(
      english:          result.english,
      japanese:         result.japanese,
      hiragana:         result.hiragana,
      notes:            result.notes,
      difficulty_level: difficulty
    )
    redirect_to phrase_card_path(@card)
  rescue => e
    redirect_to new_phrase_card_path, alert: "Generation failed: #{e.message}"
  end

  def show
    setting = AnkiPhraseSetting.current
    anki_configured = setting.persisted? && setting.deck_name.present? && setting.note_type.present?
    render Views::PhraseCards::Show.new(card: @card, anki_configured: anki_configured)
  end

  def edit
    render Views::PhraseCards::Edit.new(card: @card)
  end

  def update
    if @card.update(card_params)
      redirect_to phrase_card_path(@card), notice: "Card updated."
    else
      render Views::PhraseCards::Edit.new(card: @card), status: :unprocessable_entity
    end
  end

  def destroy
    @card.audio.purge if @card.audio.attached?
    @card.destroy
    redirect_to phrase_cards_path, notice: "Card deleted."
  end

  def generate_audio
    unless @card.hiragana.present?
      redirect_to phrase_card_path(@card), alert: "No hiragana reading to generate audio from."
      return
    end

    actor = Actor.pick_random
    unless actor
      redirect_to phrase_card_path(@card), alert: "Add an actor in Settings → Listen → Actors first."
      return
    end

    audio_data = ElevenLabsTts.call(@card.hiragana, voice_id: actor.voice_id)
    @card.audio.attach(
      io:           StringIO.new(audio_data),
      filename:     "phrase_#{@card.id}.mp3",
      content_type: "audio/mpeg"
    )
    redirect_to phrase_card_path(@card), notice: "Audio generated."
  rescue => e
    redirect_to phrase_card_path(@card), alert: "Audio generation failed: #{e.message}"
  end

  def add_to_anki
    setting = AnkiPhraseSetting.current
    unless setting.persisted? && setting.deck_name.present? && setting.note_type.present?
      redirect_to phrase_card_path(@card), alert: "Configure Anki phrase settings first."
      return
    end

    re_add = @card.added?
    AnkiConnect::PhraseExporter.new(setting).export(@card)
    redirect_to phrase_card_path(@card), notice: re_add ? "Re-added to Anki." : "Added to Anki."
  rescue => e
    redirect_to phrase_card_path(@card), alert: "Anki export failed: #{e.message}"
  end

  def audio
    redirect_to rails_blob_url(@card.audio), allow_other_host: true
  end

  def archive
    @card.update!(archived: !@card.archived)
    label = @card.archived? ? "archived" : "restored"
    redirect_to phrase_cards_path, notice: "Card #{label}."
  end

  private

  def set_card
    @card = PhraseCard.find(params[:id])
  end

  def card_params
    params.expect(phrase_card: [ :english, :context, :japanese, :hiragana, :notes, :difficulty_level ])
  end
end
