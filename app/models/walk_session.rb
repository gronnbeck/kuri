# frozen_string_literal: true

class WalkSession < ApplicationRecord
  has_many :walk_session_items, -> { order(:position) }, dependent: :destroy
  has_one_attached :audio

  enum :status, { pending: "pending", processing: "processing", ready: "ready", failed: "failed" }

  validates :name, presence: true

  def ready_items
    walk_session_items.select(&:has_audio?)
  end
end
