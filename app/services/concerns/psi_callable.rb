# frozen_string_literal: true

# Shared helpers for services that shell out to psi.
# Handles both API key auth and Claude Code OAuth token auth.
module PsiCallable
  PSI_BIN = ENV.fetch("PSI_BIN", "#{Dir.home}/.local/bin/psi")

  private

  def psi_env
    oauth_token = ENV["CLAUDE_CODE_OAUTH_TOKEN"].presence
    {
      "PSI_MODEL"               => ENV.fetch("PSI_MODEL", "claude-haiku-4-5-20251001"),
      "CLAUDE_CODE_OAUTH_TOKEN" => oauth_token,
      # Explicitly nil when using OAuth so it doesn't bleed through from the parent env
      "PSI_ANTHROPIC_API_KEY"   => oauth_token ? nil : ENV["PSI_ANTHROPIC_API_KEY"]
    }
  end
end
