# frozen_string_literal: true

class PracticeController < ApplicationController
  def index
    render ::Views::Practice::Index.new
  end

  def word_guess
    @note = Note.order("RANDOM()").first
    render ::Views::Practice::WordGuess.new(note: @note, guess: nil)
  end

  def do_word_guess
    note = Note.find_by!(anki_id: params[:note_id])
    guess = WordGuesser.call(params[:description])
    render ::Views::Practice::WordGuess.new(note: note, guess: guess)
  end

  def sentence_transformation
    render ::Views::Practice::SentenceTransformation.new
  end

  def guided_translation
    render ::Views::Practice::GuidedTranslation.new
  end

  def micro_sentences
    render ::Views::Practice::MicroSentences.new
  end

  def word_hint
    word = params[:word].to_s.strip
    return render json: { error: "missing word" }, status: :bad_request if word.blank?

    record = Word.lookup(word)
    japanese = record&.japanese || begin
      WordTranslator.call(word).tap do |jp|
        Word.create!(english: word.downcase, japanese: jp)
      end
    end
    render json: { japanese: japanese }
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def sentence_patterns
    render ::Views::Practice::SentencePatterns.new
  end

  def sentence_patterns_exercise
    pattern_index = rand(Views::Practice::SentencePatterns::PATTERNS.length)
    pattern = Views::Practice::SentencePatterns::PATTERNS[pattern_index]
    english = pattern[:practice].sample
    render ::Views::Practice::SentencePatternExercise.new(
      pattern: pattern,
      pattern_index: pattern_index,
      english: english,
      answer: nil,
      result: nil
    )
  end

  def check_sentence_pattern
    pattern_index = params[:pattern_index].to_i
    pattern = Views::Practice::SentencePatterns::PATTERNS[pattern_index]
    english = params[:english].to_s
    answer = params[:answer].to_s.strip

    result = SentencePatternChecker.call(english: english, pattern: pattern[:pattern], answer: answer)

    render ::Views::Practice::SentencePatternExercise.new(
      pattern: pattern,
      pattern_index: pattern_index,
      english: english,
      answer: answer,
      result: result
    )
  end
end
