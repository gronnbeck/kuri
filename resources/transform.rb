#!/usr/bin/env ruby
# frozen_string_literal: true

#
# Transform raw JLPT CSVs → structured ndjson per level,
# then merge into a single resources/words.ndjson.
#
# Usage: ruby resources/transform.rb

require "csv"
require "json"

LEVELS = %w[n5 n4 n3].freeze
RAW_DIR        = File.join(__dir__, "raw")
STRUCTURED_DIR = File.join(__dir__, "structured")
MERGED_PATH    = File.join(__dir__, "words.ndjson")

def transform_level(level)
  csv_path  = File.join(RAW_DIR, "#{level}.csv")
  out_path  = File.join(STRUCTURED_DIR, "#{level}.ndjson")

  rows = CSV.read(csv_path, headers: true, encoding: "UTF-8")
  File.open(out_path, "w") do |f|
    rows.each do |row|
      expression = row["expression"].to_s.strip
      reading    = row["reading"].to_s.strip
      meaning    = row["meaning"].to_s.strip
      tags       = row["tags"].to_s.split.map(&:strip).reject(&:empty?)

      next if expression.empty?

      f.puts JSON.generate(
        level:      level,
        expression: expression,
        reading:    reading,
        meaning:    meaning,
        tags:       tags
      )
    end
  end

  count = rows.size
  puts "  #{level}: #{count} words → #{out_path}"
  count
end

puts "Transforming CSV → structured ndjson..."
LEVELS.each { |l| transform_level(l) }

puts "\nMerging into #{MERGED_PATH}..."
total = 0
File.open(MERGED_PATH, "w") do |out|
  LEVELS.each do |level|
    path = File.join(STRUCTURED_DIR, "#{level}.ndjson")
    File.foreach(path) do |line|
      out.write(line)
      total += 1
    end
  end
end
puts "  Total: #{total} words → #{MERGED_PATH}"
