# frozen_string_literal: true

class VerbAudiosController < ApplicationController
  def audio
    va = VerbAudio.find(params[:id])
    redirect_to url_for(va.audio), allow_other_host: true
  end
end
