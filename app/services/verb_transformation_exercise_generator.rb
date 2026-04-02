# frozen_string_literal: true

class VerbTransformationExerciseGenerator
  include PsiCallable

  Result = Struct.new(:verb_jp, :verb_en, :verb_reading, :target_form,
                      :answer_jp, :answer_en, :answer_reading, :notes,
                      :difficulty_level,
                      keyword_init: true)

  PROMPT = <<~PROMPT
    Generate a Japanese verb conjugation exercise for a learner at JLPT %s level.

    Target form: %s
    Verb: %s
    %s

    ## Task

    %s
    Produce the correct conjugated form for the target form above.

    ## Rules

    - Choose a verb the learner is likely to encounter in daily life or textbooks at this level
    - VARY your choice — cover different verb categories (movement, food, communication, emotion, work, daily routine, etc.)
    - Do NOT reuse any verb from this list (already used): %s
    - Use kanji appropriate for the target JLPT level (avoid kanji beyond the level)
    - Provide hiragana-only readings for both the dictionary form and the answer
    - Keep notes brief and useful (grammar pattern, any irregularities, or usage tip) — null if nothing noteworthy

    ## Output

    Respond with JSON only — no markdown, no explanation.
    {
      "verb_jp":        "<verb in dictionary form — kanji/kana, e.g. 食べる>",
      "verb_en":        "<English meaning of the verb, e.g. to eat>",
      "verb_reading":   "<hiragana-only reading of verb_jp>",
      "target_form":    "<the target form key, exactly as given above>",
      "answer_jp":      "<correct conjugated form in Japanese>",
      "answer_en":      "<English description of the conjugated form, e.g. eat (polite)>",
      "answer_reading": "<hiragana-only reading of answer_jp>",
      "difficulty_level": "<JLPT level of the verb: n5, n4, n3, n2, or n1>",
      "notes":          "<optional brief English grammar note — null if not needed>"
    }
  PROMPT

  IMPROVE_PROMPT = <<~PROMPT
    You are improving an existing Japanese verb conjugation exercise based on learner feedback.

    ## Current exercise

    Verb (JP):    %s
    Verb (EN):    %s
    Target form:  %s
    Answer (JP):  %s
    Answer (EN):  %s
    Difficulty:   JLPT %s

    ## Feedback from the learner

    %s

    ## Task

    Rewrite the exercise to address the feedback. Keep the same JLPT level and target form.
    You may choose a different verb if the feedback suggests the current one is inappropriate.

    ## Output

    Respond with JSON only — no markdown, no explanation.
    {
      "verb_jp":        "<verb in dictionary form>",
      "verb_en":        "<English meaning>",
      "verb_reading":   "<hiragana-only reading of verb_jp>",
      "target_form":    "<target form key, unchanged>",
      "answer_jp":      "<correct conjugated form>",
      "answer_en":      "<English description of conjugated form>",
      "answer_reading": "<hiragana-only reading of answer_jp>",
      "notes":          "<optional brief English grammar note — null if not needed>"
    }
  PROMPT

  READINGS_PROMPT = <<~PROMPT
    Convert each Japanese text to a hiragana-only reading (no kanji, no katakana).

    Verb:   %s
    Answer: %s

    Respond with JSON only — no markdown, no explanation.
    {
      "verb_reading":   "<hiragana-only reading of the verb>",
      "answer_reading": "<hiragana-only reading of the answer>"
    }
  PROMPT

  def self.call(difficulty:, target_form: nil, verb: nil, prompt: nil, exclude_verbs: [])
    new(difficulty: difficulty, target_form: target_form, verb: verb, prompt: prompt, exclude_verbs: exclude_verbs).call
  end

  def self.improve(exercise:, feedbacks:)
    new(difficulty: exercise.difficulty_level, target_form: exercise.target_form).improve(exercise, feedbacks)
  end

  def self.readings_for(exercise:)
    new(difficulty: nil, target_form: nil).fetch_readings(exercise)
  end

  def initialize(difficulty:, target_form:, verb: nil, prompt: nil, exclude_verbs: [])
    @difficulty     = difficulty
    @target_form    = target_form
    @verb           = verb
    @prompt         = prompt
    @exclude_verbs  = Array(exclude_verbs)
  end

  def call
    stdout, stderr = run_psi(build_prompt)
    parse_result(stdout, stderr)
  end

  def improve(exercise, feedbacks)
    feedback_text = feedbacks.map.with_index(1) { |f, i| "#{i}. #{f.body}" }.join("\n")
    full_prompt = format(
      IMPROVE_PROMPT,
      exercise.verb_jp, exercise.verb_en,
      exercise.target_form_label,
      exercise.answer_jp, exercise.answer_en,
      exercise.difficulty_level.upcase,
      feedback_text
    )
    stdout, stderr = run_psi(full_prompt)
    parse_result(stdout, stderr)
  end

  def fetch_readings(exercise)
    prompt = format(READINGS_PROMPT, exercise.verb_jp, exercise.answer_jp)
    stdout, stderr = run_psi(prompt)
    lines = stdout.lines.map { |l| JSON.parse(l.strip) rescue nil }.compact
    raise "psi error: #{lines.find { |l| l["type"] == "error" }&.dig("message")}" if lines.any? { |l| l["type"] == "error" }
    response = lines.find { |l| l["type"] == "response" }
    raise "psi failed: #{stderr.lines.first&.strip || "no response"}" unless response
    data = extract_json(response["content"])
    {
      verb_reading:   data["verb_reading"].to_s.strip.presence,
      answer_reading: data["answer_reading"].to_s.strip.presence
    }
  rescue JSON::ParserError => e
    raise "unexpected LLM response format: #{e.message}"
  end

  private

  def parse_result(stdout, stderr)
    lines = stdout.lines.map { |l| JSON.parse(l.strip) rescue nil }.compact

    if (err = lines.find { |l| l["type"] == "error" })
      raise "psi error: #{err["message"]}"
    end

    response = lines.find { |l| l["type"] == "response" }
    raise "psi failed: #{stderr.lines.first&.strip || "no response"}" unless response

    data = extract_json(response["content"])
    Result.new(
      verb_jp:          data["verb_jp"].to_s.strip,
      verb_en:          data["verb_en"].to_s.strip,
      verb_reading:     data["verb_reading"].to_s.strip.presence,
      target_form:      data["target_form"].to_s.strip,
      answer_jp:        data["answer_jp"].to_s.strip,
      answer_en:        data["answer_en"].to_s.strip,
      answer_reading:   data["answer_reading"].to_s.strip.presence,
      difficulty_level: data["difficulty_level"].to_s.strip.presence,
      notes:            data["notes"].presence
    )
  end

  def build_prompt
    if @target_form
      label      = VerbTransformationExercise::TARGET_FORM_LABELS.fetch(@target_form, @target_form)
      form_label = "#{label} (key: \"#{@target_form}\")"
    else
      form_label = "any appropriate form — choose the key from: #{VerbTransformationExercise::TARGET_FORMS.join(", ")}"
    end
    if @verb.present?
      level     = @difficulty&.upcase || "appropriate"
      verb_line = @verb
      task_line = "Use the verb provided above. Infer the appropriate JLPT level from the verb itself."
    else
      level     = @difficulty.upcase
      verb_line = "— (pick a natural verb appropriate for JLPT #{level})"
      task_line = "Pick a natural, commonly-used Japanese verb appropriate for JLPT #{level}."
    end
    extra         = @prompt.present? ? "Additional instructions: #{@prompt}" : ""
    exclude_line  = @exclude_verbs.any? ? @exclude_verbs.join(", ") : "none"
    format(PROMPT, level, form_label, verb_line, extra, task_line, exclude_line)
  end

  def run_psi(prompt)
    Bundler.with_unbundled_env do
      stdout, stderr, _status = Open3.capture3(psi_env, PSI_BIN, "--pp", *PSI_NO_TOOLS_FLAGS, stdin_data: prompt)
      [ stdout, stderr ]
    end
  rescue Errno::ENOENT
    raise "psi not found at #{PSI_BIN}. Set PSI_BIN env var."
  end


  def extract_json(content)
    json = content.to_s.strip
    # Strip markdown code fences if present
    json = json.gsub(/\A```(?:json)?\n?/, "").gsub(/\n?```\z/, "").strip
    # If the model prefixed the JSON with prose, pull out the first {...} block
    json = json[/\{.*\}/m] || json
    JSON.parse(json)
  rescue JSON::ParserError => e
    raise "unexpected LLM response format: #{e.message}"
  end
end
