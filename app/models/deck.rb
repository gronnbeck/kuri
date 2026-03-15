# frozen_string_literal: true

class Deck < ApplicationRecord
  has_many :notes, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  scope :sync_enabled, -> { where(sync_enabled: true) }
end
