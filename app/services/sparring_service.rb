# frozen_string_literal: true

class SparringService
  include PsiCallable

  SYSTEM_PROMPT = <<~PROMPT
    You are a Japanese learning assistant for the Kuri app.
    You have tools to query, search, and create content in Kuri:
    - Conversation exercise cards (request/response pairs for situational practice)
    - Standalone phrase cards (individual words, expressions, or example sentences)
    Always search existing exercises and phrases before creating new ones to avoid duplicates.
    When creating conversation exercises: the learner always plays the CUSTOMER / GUEST role, never staff.
    Respond in plain text — no JSON, no markdown code blocks.
  PROMPT

  def self.call(message:, history: [])
    new(message: message, history: history).call
  end

  def initialize(message:, history: [])
    @message = message
    @history = history
  end

  def call
    stdout, stderr = run_psi(build_ndjson)

    lines = stdout.lines.map { |l| JSON.parse(l.strip) rescue nil }.compact

    if (err = lines.find { |l| l["type"] == "error" })
      raise "psi error: #{err["message"]}"
    end

    response = lines.find { |l| l["type"] == "response" }
    raise "psi failed: #{stderr.lines.first&.strip || "no response"}" unless response

    response["content"].strip
  end

  private

  def build_ndjson
    lines = []
    lines << { role: "user", content: SYSTEM_PROMPT }.to_json

    @history.each do |turn|
      lines << { role: turn["role"], content: turn["content"] }.to_json
    end

    lines << { role: "prompt", content: @message }.to_json
    lines.join("\n")
  end

  def run_psi(ndjson)
    Bundler.with_unbundled_env do
      stdout, stderr, _status = Open3.capture3(
        psi_env, PSI_BIN, "--pp", "--input-type", "ndjson",
        stdin_data: ndjson
      )
      [ stdout, stderr ]
    end
  rescue Errno::ENOENT
    raise "psi not found at #{PSI_BIN}. Set PSI_BIN env var."
  end
end
