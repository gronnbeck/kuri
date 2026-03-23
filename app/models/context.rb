# frozen_string_literal: true

class Context < ApplicationRecord
  has_many :conversation_exercises

  validates :name, presence: true
end
