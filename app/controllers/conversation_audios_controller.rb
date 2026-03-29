# frozen_string_literal: true

class ConversationAudiosController < ApplicationController
  def audio
    ca = ConversationAudio.find(params[:id])
    blob = params[:pending] == "1" ? ca.pending_audio : ca.audio
    raise ActiveRecord::RecordNotFound unless blob.attached?
    redirect_to rails_blob_url(blob), allow_other_host: true
  end
end
