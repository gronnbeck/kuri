# frozen_string_literal: true

class ActorsController < ApplicationController
  def index
    @actors = Actor.order(:created_at)
    render ::Views::Actors::Index.new(actors: @actors)
  end

  def create
    Actor.create!(
      name:     params[:name].presence,
      voice_id: params[:voice_id].to_s.strip,
      gender:   params[:gender].presence
    )
    redirect_to settings_listen_actors_path, notice: "Actor added."
  rescue => e
    redirect_to settings_listen_actors_path, alert: "Failed: #{e.message}"
  end

  def edit
    @actor = Actor.find(params[:id])
    render ::Views::Actors::Edit.new(actor: @actor)
  end

  def update
    actor = Actor.find(params[:id])
    actor.update!(
      name:     params[:name].presence,
      voice_id: params[:voice_id].to_s.strip,
      gender:   params[:gender].presence
    )
    redirect_to settings_listen_actors_path, notice: "Actor updated."
  rescue => e
    redirect_to settings_listen_actors_path, alert: "Failed: #{e.message}"
  end

  def destroy
    Actor.find(params[:id]).destroy
    redirect_to settings_listen_actors_path, notice: "Actor removed."
  end
end
