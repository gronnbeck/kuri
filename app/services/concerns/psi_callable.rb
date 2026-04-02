# frozen_string_literal: true

# Shared helpers for services that shell out to psi.
# Handles both API key auth and Claude Code OAuth token auth.
module PsiCallable
  PSI_BIN = ENV.fetch("PSI_BIN", "#{Dir.home}/.local/bin/psi")

  private

  def psi_env
    {
      "PSI_ANTHROPIC_API_KEY" => ENV["PSI_ANTHROPIC_API_KEY"],
      "PSI_MODEL"             => ENV.fetch("PSI_MODEL", "claude-haiku-4-5-20251001")
    }.compact
  end
end
