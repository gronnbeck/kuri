# frozen_string_literal: true

class Views::Settings::CardTemplates < ApplicationView
  # ── Conversation templates ──────────────────────────────────────────────────

  CONV_FRONT = <<~HTML.freeze
    <div class="kuri">
      <div class="kuri-request">{{request}}</div>
      {{#request_reading}}<div class="kuri-reading">{{request_reading}}</div>{{/request_reading}}
      <div class="kuri-audio">{{request_audio}}</div>
      <div class="kuri-meta">
        {{#context}}<span class="kuri-badge kuri-badge--context">{{context}}</span>{{/context}}
        {{#difficulty}}<span class="kuri-badge">{{difficulty}}</span>{{/difficulty}}
      </div>
    </div>
  HTML

  CONV_BACK = <<~HTML.freeze
    {{FrontSide}}
    <hr class="kuri-divider">
    <div class="kuri">
      <div class="kuri-response">{{response}}</div>
      {{#response_reading}}<div class="kuri-reading">{{response_reading}}</div>{{/response_reading}}
      <div class="kuri-audio">{{response_audio}}</div>
      {{#notes}}<div class="kuri-notes">{{notes}}</div>{{/notes}}
    </div>
  HTML

  # ── Verb templates ──────────────────────────────────────────────────────────

  VERB_FRONT = <<~HTML.freeze
    <div class="kuri">
      <div class="kuri-request">{{verb}}</div>
      {{#verb_reading}}<div class="kuri-reading">{{verb_reading}}</div>{{/verb_reading}}
      <div class="kuri-audio">{{verb_audio}}</div>
      {{#verb_en}}<div class="kuri-en kuri-en--hint">{{verb_en}}</div>{{/verb_en}}
      <div class="kuri-target-form">&#x2192;&nbsp;{{target_form}}</div>
      {{#difficulty}}<div class="kuri-meta"><span class="kuri-badge">{{difficulty}}</span></div>{{/difficulty}}
    </div>
  HTML

  VERB_BACK = <<~HTML.freeze
    {{FrontSide}}
    <hr class="kuri-divider">
    <div class="kuri">
      <div class="kuri-response">{{answer}}</div>
      {{#answer_reading}}<div class="kuri-reading">{{answer_reading}}</div>{{/answer_reading}}
      <div class="kuri-audio">{{answer_audio}}</div>
      {{#answer_en}}<div class="kuri-en">{{answer_en}}</div>{{/answer_en}}
      {{#notes}}<div class="kuri-notes">{{notes}}</div>{{/notes}}
    </div>
  HTML

  # ── Shared CSS ──────────────────────────────────────────────────────────────

  SHARED_CSS = <<~CSS.freeze
    .card {
      background: #ffffff;
      font-family: "Hiragino Sans", "Noto Sans JP", system-ui, sans-serif;
      color: #1a1a1a;
    }

    .kuri {
      max-width: 480px;
      margin: 0 auto;
      padding: 1.25rem 1rem;
    }

    .kuri-request,
    .kuri-response {
      font-size: 2rem;
      font-weight: 700;
      line-height: 1.3;
      margin-bottom: 0.4rem;
    }

    .kuri-reading {
      font-size: 0.95rem;
      color: #64748b;
      margin-bottom: 0.75rem;
    }

    .kuri-audio {
      margin: 0.5rem 0;
    }

    .kuri-en {
      font-size: 0.95rem;
      color: #475569;
      margin-bottom: 0.5rem;
    }

    .kuri-en--hint {
      font-style: italic;
      color: #94a3b8;
    }

    .kuri-target-form {
      display: inline-block;
      margin: 0.75rem 0 0.25rem;
      font-size: 1rem;
      font-weight: 700;
      color: #7c3aed;
      background: #ede9fe;
      border-radius: 6px;
      padding: 0.2rem 0.6rem;
    }

    .kuri-notes {
      font-size: 0.8rem;
      color: #94a3b8;
      border-top: 1px solid #f1f5f9;
      margin-top: 0.75rem;
      padding-top: 0.6rem;
    }

    .kuri-meta {
      margin-top: 0.75rem;
      display: flex;
      gap: 0.35rem;
      flex-wrap: wrap;
    }

    .kuri-badge {
      font-size: 0.7rem;
      font-weight: 700;
      padding: 0.15rem 0.5rem;
      border-radius: 4px;
      background: #f1f5f9;
      color: #475569;
      text-transform: uppercase;
      letter-spacing: 0.03em;
    }

    .kuri-badge--context {
      background: #e0f2fe;
      color: #0369a1;
      text-transform: none;
      font-weight: 600;
    }

    .kuri-divider {
      border: none;
      border-top: 1px solid #e2e8f0;
      margin: 1.25rem 0;
    }

    @media (max-width: 480px) {
      .kuri {
        padding: 1rem 0.75rem;
      }

      .kuri-request,
      .kuri-response {
        font-size: 1.6rem;
      }
    }
  CSS

  def initialize(conv_setting:, verb_setting:)
    @conv_setting = conv_setting
    @verb_setting = verb_setting
  end

  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Settings", path: helpers.settings_path },
        { label: "Listen",   path: helpers.settings_listen_path },
        { label: "Card Templates" }
      ])
      h1 { "Anki Card Templates" }
    end

    div(class: "exercise-content") do
      div(class: "exercise-section") do
        p(class: "exercise-instructions") do
          plain "Copy each block into the corresponding field in Anki's card template editor "
          plain "(Browse → select a note type → Cards…)."
        end

        sections.each do |section|
          h2(class: "mt-2") { section[:title] }

          section[:blocks].each do |block|
            div(class: "card-template-block", data: { controller: "clipboard" }) do
              div(class: "card-template-header") do
                span(class: "card-template-label") { block[:label] }
                button(
                  type: "button",
                  class: "button button--ghost button--small",
                  data: { action: "click->clipboard#copy", clipboard_target: "button" }
                ) { "Copy" }
              end
              pre(
                class: "card-template-code",
                data: { clipboard_target: "source" }
              ) { block[:content] }
            end
          end
        end
      end
    end
  end

  private

  def sections
    [
      {
        title:  "Conversation Cards",
        blocks: [
          { label: "Front", content: apply_mappings(CONV_FRONT, @conv_setting) },
          { label: "Back",  content: apply_mappings(CONV_BACK,  @conv_setting) },
          { label: "CSS",   content: SHARED_CSS }
        ]
      },
      {
        title:  "Verb Exercise Cards",
        blocks: [
          { label: "Front", content: apply_mappings(VERB_FRONT, @verb_setting) },
          { label: "Back",  content: apply_mappings(VERB_BACK,  @verb_setting) },
          { label: "CSS",   content: SHARED_CSS }
        ]
      }
    ]
  end

  # Replace {{source_field}} placeholders with the Anki field names from the setting's
  # field_mappings (which map anki_field_name → source_field_name). Falls back to the
  # source field name when no custom mapping exists.
  def apply_mappings(template, setting)
    mappings = setting&.field_mappings.presence || {}
    # Build reverse: source_field_name → anki_field_name
    reverse = mappings.invert
    template.gsub(/\{\{([#\/]?)(\w+)\}\}/) do |match|
      prefix = Regexp.last_match(1)
      source = Regexp.last_match(2)
      anki_name = reverse[source]
      anki_name ? "{{#{prefix}#{anki_name}}}" : match
    end
  end
end
