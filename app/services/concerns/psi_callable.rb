# frozen_string_literal: true

# Shared helpers for services that shell out to psi.
module PsiCallable
  PSI_BIN = ENV.fetch("PSI_BIN", "#{Dir.home}/.local/bin/psi")

  # Flags for pure generation calls — bypasses .psi/settings.yml so psi
  # doesn't load Kuri's custom tools and try to use them instead of returning JSON.
  PSI_NO_TOOLS_FLAGS = [ "--config", "/dev/null" ].freeze

  private

  # Runs a block with the given prompt, retrying up to max_attempts times on failure.
  # On each retry, a corrective note is prepended so the model knows what went wrong.
  def with_json_retry(prompt, max_attempts: 3)
    attempts = 0
    current_prompt = prompt
    begin
      attempts += 1
      yield current_prompt
    rescue => e
      raise if attempts >= max_attempts

      current_prompt = <<~RETRY
        IMPORTANT: Your previous response could not be parsed as JSON.
        Error: #{e.message.split("\n").first}
        You MUST respond with ONLY a valid JSON object — no text before it, no text after it, no markdown.

        #{prompt}
      RETRY
      retry
    end
  end

  def psi_env
    {
      "PSI_ANTHROPIC_API_KEY" => ENV["PSI_ANTHROPIC_API_KEY"],
      "PSI_MODEL"             => ENV.fetch("PSI_MODEL", "claude-haiku-4-5-20251001")
    }.compact
  end
end
