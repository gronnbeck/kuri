# frozen_string_literal: true

# rake jlpt:generate_all                      # everything — all levels, both types, no limit
# rake jlpt:generate                          # all levels, both types, limit 20
# rake jlpt:generate[n5]                      # N5 only
# rake jlpt:generate[n5,phrase]               # N5 phrase cards only
# rake jlpt:generate[n5,conversation,50]      # N5 conversation exercises, 50 words
# rake jlpt:generate[all,both,all]            # all levels, both types, no limit

namespace :jlpt do
  desc "Generate everything — all N3/N4/N5 words as phrase cards and conversation exercises"
  task generate_all: :environment do
    Rake::Task["jlpt:generate"].invoke("all", "both", "all")
  end

  desc "Generate phrase cards and/or conversation exercises from JLPT word list"
  task :generate, [ :level, :type, :limit ] => :environment do |_t, args|
    level = (args[:level].presence || "all").downcase
    type  = (args[:type].presence  || "both").downcase
    limit_arg = args[:limit].presence || "20"
    limit = limit_arg == "all" ? Float::INFINITY : limit_arg.to_i

    levels = level == "all" ? %w[n5 n4 n3] : [ level ]
    unless (levels - %w[n5 n4 n3]).empty?
      abort "Unknown level '#{level}'. Use: n5, n4, n3, or all."
    end
    unless %w[phrase conversation both].include?(type)
      abort "Unknown type '#{type}'. Use: phrase, conversation, or both."
    end

    words_path = Rails.root.join("resources/words.ndjson")
    abort "resources/words.ndjson not found. Run ruby resources/transform.rb first." unless words_path.exist?

    words = File.foreach(words_path).map { |line| JSON.parse(line.strip) rescue nil }.compact
    words = words.select { |w| levels.include?(w["level"]) }

    puts "Loaded #{words.size} words for level(s): #{levels.join(", ")}"
    puts "Type: #{type} | Limit: #{limit == Float::INFINITY ? "unlimited" : limit}"
    puts

    generated = 0
    skipped   = 0
    errors    = 0

    words.each do |word|
      break if generated >= limit

      expression = word["expression"]
      reading    = word["reading"]
      meaning    = word["meaning"]
      diff       = word["level"]

      if type == "phrase" || type == "both"
        if PhraseCard.exists?(japanese: expression)
          skipped += 1
          puts "  [skip]  #{expression} — phrase card already exists"
        else
          begin
            result = PhraseCardGenerator.call(
              prompt:     "#{expression} — #{meaning}",
              english:    nil,
              difficulty: diff
            )
            japanese = result.japanese.presence || expression
            next if PhraseCard.exists?(japanese: japanese)
            PhraseCard.create!(
              japanese:         japanese,
              hiragana:         result.hiragana.presence || reading,
              english:          result.english,
              notes:            result.notes,
              difficulty_level: diff
            )
            generated += 1
            puts "  [phrase]  #{expression} (#{diff.upcase}) → #{result.english}"
          rescue => e
            errors += 1
            puts "  [error]   #{expression} phrase: #{e.message}"
          end
        end
      end

      break if generated >= limit

      if type == "conversation" || type == "both"
        already = ConversationExercise.where(
          "request_jp LIKE ? OR response_jp LIKE ?",
          "%#{expression}%", "%#{expression}%"
        ).exists?

        if already
          skipped += 1
          puts "  [skip]  #{expression} — conversation exercise already exists"
        else
          begin
            result = ConversationExerciseGenerator.call(
              context_name: nil,
              difficulty:   diff,
              prompt:       "Use the word #{expression} (#{meaning}) naturally in the conversation"
            )
            context = Context.find_or_create_by!(name: result.context_name) if result.context_name.present?
            ConversationExercise.create!(
              context:          context,
              difficulty_level: diff,
              request_jp:       result.request_jp,
              request_en:       result.request_en,
              request_reading:  result.request_reading,
              response_jp:      result.response_jp,
              response_en:      result.response_en,
              response_reading: result.response_reading,
              notes:            result.notes
            )
            generated += 1
            puts "  [convo]   #{expression} (#{diff.upcase}) → #{result.context_name}: #{result.request_en}"
          rescue => e
            errors += 1
            puts "  [error]   #{expression} conversation: #{e.message}"
          end
        end
      end
    end

    puts
    puts "Done. Generated: #{generated} | Skipped (duplicates): #{skipped} | Errors: #{errors}"
  end
end
