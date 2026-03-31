# frozen_string_literal: true

class WalkSessionItem < ApplicationRecord
  belongs_to :walk_session
  belongs_to :item, polymorphic: true

  ALLOWED_TYPES = %w[ConversationExercise PhraseCard VerbTransformationExercise].freeze

  validates :item_type, inclusion: { in: ALLOWED_TYPES }

  def label
    case item
    when ConversationExercise
      "#{item.request_en.presence || item.request_jp} → #{item.response_en.presence || item.response_jp}"
    when PhraseCard
      item.english
    when VerbTransformationExercise
      "#{item.verb_en.presence || item.verb} → #{item.target_form_label}"
    end
  end

  def sub_label
    case item
    when ConversationExercise
      [ item.context&.name, item.difficulty_level&.upcase ].compact.join(" · ")
    when PhraseCard
      [ item.context, item.difficulty_level&.upcase ].compact.join(" · ")
    when VerbTransformationExercise
      item.difficulty_level&.upcase
    end
  end

  def has_audio?
    case item
    when ConversationExercise
      item.request_audio&.audio&.attached? || item.response_audio&.audio&.attached?
    when PhraseCard
      item.audio.attached?
    when VerbTransformationExercise
      item.verb_audio&.audio&.attached? || item.answer_audio&.audio&.attached?
    end
  end

  # Returns ordered list of [audio_record_or_attachment, label] pairs for this item
  def audio_segments
    case item
    when ConversationExercise
      segs = []
      segs << item.request_audio  if item.request_audio&.audio&.attached?
      segs << item.response_audio if item.response_audio&.audio&.attached?
      segs
    when PhraseCard
      item.audio.attached? ? [ item ] : []
    when VerbTransformationExercise
      segs = []
      segs << item.verb_audio   if item.verb_audio&.audio&.attached?
      segs << item.answer_audio if item.answer_audio&.audio&.attached?
      segs
    end
  end
end
