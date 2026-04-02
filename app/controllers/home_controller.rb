# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    stats = {
      phrases:       PhraseCard.where(archived: false).count,
      conversations: ConversationExercise.where(archived: false).count,
      verbs:         VerbTransformationExercise.where(archived: false).count,
      notes:         Note.count,
      words:         Word.count,
      contexts:      Context.count
    }
    render ::Views::Home::Index.new(stats: stats)
  end
end
