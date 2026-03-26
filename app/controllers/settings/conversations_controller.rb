# frozen_string_literal: true

module Settings
  class ConversationsController < ApplicationController
    def show
      @setting = AnkiConversationSetting.current
      render Views::Settings::Conversations.new(setting: @setting)
    end

    def update
      @setting = AnkiConversationSetting.current
      if @setting.update(setting_params)
        redirect_to settings_listen_conversations_path, notice: "Settings saved."
      else
        render Views::Settings::Conversations.new(setting: @setting), status: :unprocessable_entity
      end
    end

    def fetch_decks
      client = anki_client
      decks  = client.deck_names
      render json: { decks: decks }
    rescue AnkiConnect::Client::ConnectionError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def fetch_note_types
      client = anki_client
      types  = client.model_names
      render json: { note_types: types }
    rescue AnkiConnect::Client::ConnectionError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def fetch_fields
      client     = anki_client
      note_type  = params[:note_type]
      fields     = client.model_field_names(note_type)
      render json: { fields: fields }
    rescue AnkiConnect::Client::ConnectionError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def test_connection
      client = anki_client
      client.deck_names
      render json: { ok: true }
    rescue AnkiConnect::Client::ConnectionError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def anki_client
      url = params[:url].presence || AnkiConversationSetting.current.url || AnkiConnect::Client::DEFAULT_URL
      AnkiConnect::Client.new(url: url)
    end

    def setting_params
      permitted = params.expect(anki_conversation_setting: [ :url, :deck_name, :note_type, { field_mappings: {} } ])
      permitted[:field_mappings] ||= {}
      # Discard entries with a blank Anki field name (incomplete rows)
      permitted[:field_mappings].reject! { |k, _| k.blank? }
      permitted
    end
  end
end
