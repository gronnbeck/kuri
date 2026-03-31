# frozen_string_literal: true

class SentencesController < ApplicationController
  def destroy
    sentence = Sentence.find(params[:id])
    sentence.clips.each { |c| c.audio.purge }
    sentence.destroy
    redirect_to audio_clips_generate_path, notice: "Sentence and all clips deleted."
  end
end
