# frozen_string_literal: true

class AnkiConversationSetting < ApplicationRecord
  def self.current
    first_or_initialize
  end
end
