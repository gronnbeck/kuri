# frozen_string_literal: true

class VerbAudiosController < ApplicationController
  def audio
    va = VerbAudio.find(params[:id])
    blob = params[:pending] == "1" ? va.pending_audio : va.audio
    raise ActiveRecord::RecordNotFound unless blob.attached?
    redirect_to rails_blob_url(blob), allow_other_host: true
  end
end
