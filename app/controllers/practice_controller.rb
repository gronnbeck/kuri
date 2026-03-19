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
    sentences = Views::Practice::SentenceTransformation::SENTENCES
    idx = rand(sentences.length)
    render ::Views::Practice::SentenceTransformation.new(
      sentence: sentences[idx], sentence_index: idx, answer: nil, result: nil
    )
  end

  def check_sentence_transformation
    sentences = Views::Practice::SentenceTransformation::SENTENCES
    idx       = params[:sentence_index].to_i
    sentence  = sentences[idx]
    answer    = params[:answer].to_s.strip
    result    = SentencePatternChecker.call(
      english: sentence[:en],
      pattern: "a transformation of the base sentence 私はコーヒーを飲みます",
      answer:  answer
    )
    render ::Views::Practice::SentenceTransformation.new(
      sentence: sentence, sentence_index: idx, answer: answer, result: result
    )
  end

  def guided_translation
    sentences = TranslationSentence.order("RANDOM()").limit(10)
    render ::Views::Practice::GuidedTranslation.new(sentences: sentences)
  end

  def guided_translation_exercise
    sentence = TranslationSentence.order("RANDOM()").first
    render ::Views::Practice::GuidedTranslationExercise.new(sentence: sentence, answer: nil, result: nil)
  end

  def check_guided_translation
    sentence = TranslationSentence.find(params[:sentence_id])
    answer   = params[:answer].to_s.strip
    result   = SentencePatternChecker.call(
      english: sentence.english,
      pattern: "natural beginner Japanese",
      answer:  answer
    )
    render ::Views::Practice::GuidedTranslationExercise.new(sentence: sentence, answer: answer, result: result)
  end

  def generate_translation_sentence
    sentence = TranslationSentenceGenerator.call
    redirect_to practice_guided_translation_path,
      notice: "Added: \"#{sentence.english}\""
  rescue => e
    redirect_to practice_guided_translation_path, alert: e.message
  end

  def daily_conversations
    render ::Views::Practice::DailyConversations.new
  end

  def daily_conversations_exercise
    theme_key = params[:theme].to_s
    theme = Views::Practice::DailyConversations::THEMES[theme_key]
    return redirect_to practice_daily_conversations_path, alert: "Unknown theme." unless theme

    result = ConversationPartner.call(theme_name: theme[:name], scenario: theme[:scenario], history: [])
    render ::Views::Practice::DailyConversationExercise.new(
      theme_key:          theme_key,
      theme:              theme,
      history:            [],
      current_staff_line: { "jp" => result.next_line_jp, "en" => result.next_line_en, "furigana" => result.next_line_furigana },
      scenario_complete:  result.scenario_complete
    )
  end

  def check_daily_conversation
    theme_key = params[:theme_key].to_s
    theme = Views::Practice::DailyConversations::THEMES[theme_key]
    return redirect_to practice_daily_conversations_path, alert: "Unknown theme." unless theme

    history    = JSON.parse(params[:history].to_s.presence || "[]") rescue []
    user_input = params[:answer].to_s.strip

    history_with_staff = history + [ {
      "role"     => "staff",
      "jp"       => params[:current_staff_line_jp].to_s,
      "en"       => params[:current_staff_line_en].to_s,
      "furigana" => params[:current_staff_line_furigana].to_s
    } ]

    result = ConversationPartner.call(
      theme_name: theme[:name],
      scenario:   theme[:scenario],
      history:    history_with_staff,
      user_input: user_input
    )

    new_history = history_with_staff + [ {
      "role"     => "customer",
      "jp"       => user_input,
      "feedback" => result.feedback,
      "correct"  => result.correct
    } ]

    render ::Views::Practice::DailyConversationExercise.new(
      theme_key:          theme_key,
      theme:              theme,
      history:            new_history,
      current_staff_line: result.scenario_complete ? nil : { "jp" => result.next_line_jp, "en" => result.next_line_en, "furigana" => result.next_line_furigana },
      scenario_complete:  result.scenario_complete
    )
  end

  def micro_sentences
    render ::Views::Practice::MicroSentences.new
  end

  def word_hint
    word = params[:word].to_s.strip
    return render json: { error: "missing word" }, status: :bad_request if word.blank?

    record = Word.lookup(word) || begin
      result = WordTranslator.call(word)
      Word.create!(
        english:     word.downcase,
        japanese:    result.japanese,
        furigana:    result.furigana,
        description: result.description
      )
    end
    render json: { japanese: record.japanese, furigana: record.furigana, description: record.description }
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def jp_word_hint
    word = params[:word].to_s.strip
    return render json: { error: "missing word" }, status: :bad_request if word.blank?

    result = JpWordTranslator.call(word)
    text = result.furigana.present? ? "#{result.english} (#{result.furigana})" : result.english
    render json: { english: text, furigana: result.furigana }
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
