# frozen_string_literal: true

class Word < ApplicationRecord
  validates :english, presence: true, uniqueness: { case_sensitive: false }
  validates :japanese, presence: true

  def self.lookup(english)
    find_by("LOWER(english) = ?", english.downcase)
  end
end
