# frozen_string_literal: true

class VerbTransformationExercise < ApplicationRecord
  TARGET_FORMS = %w[
    te_form ta_form masu_form nai_form
    potential passive causative volitional
    conditional_ba conditional_tara imperative te_iru
  ].freeze

  TARGET_FORM_LABELS = {
    "te_form"          => "て-form",
    "ta_form"          => "た-form",
    "masu_form"        => "ます-form",
    "nai_form"         => "ない-form",
    "potential"        => "Potential",
    "passive"          => "Passive",
    "causative"        => "Causative",
    "volitional"       => "Volitional",
    "conditional_ba"   => "Conditional (ば)",
    "conditional_tara" => "Conditional (たら)",
    "imperative"       => "Imperative",
    "te_iru"           => "ている-form"
  }.freeze

  has_many :verb_audios, dependent: :destroy
  has_one :verb_audio,   -> { where(kind: "verb") },   class_name: "VerbAudio"
  has_one :answer_audio, -> { where(kind: "answer") }, class_name: "VerbAudio"
  has_many :verb_transformation_feedbacks, dependent: :destroy
  has_many :verb_anki_exports, dependent: :destroy

  LABEL_TO_KEY = TARGET_FORM_LABELS.invert.freeze

  enum :difficulty_level, { n5: "n5", n4: "n4", n3: "n3", n2: "n2", n1: "n1" }
  enum :anki_status, { not_added: "not_added", added: "added", failed: "failed" }

  before_validation :normalise_target_form

  validates :verb_jp, :answer_jp, :difficulty_level, presence: true
  validates :target_form, presence: true, inclusion: { in: TARGET_FORMS }

  def target_form_label
    TARGET_FORM_LABELS[target_form] || target_form
  end

  private

  def normalise_target_form
    return if target_form.blank? || TARGET_FORMS.include?(target_form)
    self.target_form = LABEL_TO_KEY[target_form] || target_form
  end
end
