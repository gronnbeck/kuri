# frozen_string_literal: true

class AudioClipsController < ApplicationController
  def index
    @actors    = Actor.order(:created_at)
    @sentences = Sentence.includes(clips: [ :actor, { audio_attachment: :blob } ]).order(created_at: :desc)
    render ::Views::AudioClips::Index.new(actors: @actors, sentences: @sentences)
  end

  def create
    text     = params[:text].to_s.strip
    actor_id = params[:actor_id].to_s.strip

    if text.blank? || actor_id.blank?
      redirect_to audio_clips_path, alert: "Text and actor are required."
      return
    end

    actor = Actor.find(actor_id)
    Clip.find_or_generate(sentence_text: text, actor: actor)
    redirect_to audio_clips_path, notice: "Clip ready."
  rescue => e
    redirect_to audio_clips_path, alert: "Failed to generate clip: #{e.message}"
  end

  def audio
    clip = Clip.find(params[:id])
    redirect_to rails_blob_url(clip.audio), allow_other_host: true
  end
end
