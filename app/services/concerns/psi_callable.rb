# frozen_string_literal: true

# Shared helpers for services that shell out to psi.
module PsiCallable
  PSI_BIN = ENV.fetch("PSI_BIN", "#{Dir.home}/.local/bin/psi")

  # Flags for pure generation calls — bypasses .psi/settings.yml so psi
  # doesn't load Kuri's custom tools and try to use them instead of returning JSON.
  PSI_NO_TOOLS_FLAGS = [ "--config", "/dev/null" ].freeze

  private

  def psi_env
    {
      "PSI_ANTHROPIC_API_KEY" => ENV["PSI_ANTHROPIC_API_KEY"],
      "PSI_MODEL"             => ENV.fetch("PSI_MODEL", "claude-haiku-4-5-20251001")
    }.compact
  end
end
