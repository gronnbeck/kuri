# frozen_string_literal: true

class AnkiVerbSetting < ApplicationRecord
  def self.current
    first_or_initialize
  end
end
