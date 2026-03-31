# frozen_string_literal: true

module Settings
  class PhrasesController < ApplicationController
    def show
      @setting = AnkiPhraseSetting.current
      render Views::Settings::Phrases.new(setting: @setting)
    end

    def update
      @setting = AnkiPhraseSetting.current
      if @setting.update(setting_params)
        redirect_to settings_listen_phrases_path, notice: "Settings saved."
      else
        render Views::Settings::Phrases.new(setting: @setting), status: :unprocessable_entity
      end
    end

    def fetch_decks
      render json: { decks: anki_client.deck_names }
    rescue AnkiConnect::Client::ConnectionError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def fetch_note_types
      render json: { note_types: anki_client.model_names }
    rescue AnkiConnect::Client::ConnectionError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def fetch_fields
      render json: { fields: anki_client.model_field_names(params[:note_type]) }
    rescue AnkiConnect::Client::ConnectionError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def test_connection
      anki_client.deck_names
      render json: { ok: true }
    rescue AnkiConnect::Client::ConnectionError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def anki_client
      url = params[:url].presence || AnkiPhraseSetting.current.url || AnkiConnect::Client::DEFAULT_URL
      AnkiConnect::Client.new(url: url)
    end

    def setting_params
      permitted = params.expect(anki_phrase_setting: [ :url, :deck_name, :note_type, { field_mappings: {} } ])
      permitted[:field_mappings] ||= {}
      permitted[:field_mappings].reject! { |k, _| k.blank? }
      permitted
    end
  end
end
