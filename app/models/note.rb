# frozen_string_literal: true

class Note < ApplicationRecord
  belongs_to :deck

  validates :anki_id, presence: true, uniqueness: true
end
