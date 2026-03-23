# frozen_string_literal: true

class ConversationAudiosController < ApplicationController
  def audio
    ca = ConversationAudio.find(params[:id])
    redirect_to rails_blob_url(ca.audio), allow_other_host: true
  end
end
