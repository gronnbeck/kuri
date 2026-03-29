# frozen_string_literal: true

module Settings
  class CardTemplatesController < ApplicationController
    def show
      render Views::Settings::CardTemplates.new(
        conv_setting: AnkiConversationSetting.current,
        verb_setting: AnkiVerbSetting.current
      )
    end
  end
end
