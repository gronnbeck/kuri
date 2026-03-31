# frozen_string_literal: true

class AnkiPhraseSetting < ApplicationRecord
  def self.current
    first_or_initialize
  end
end
