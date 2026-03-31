# frozen_string_literal: true

class Views::WalkSessions::Show < ApplicationView
  def initialize(walk_session:, conversations:, phrases:, verbs:)
    @walk_session  = walk_session
    @conversations = conversations
    @phrases       = phrases
    @verbs         = verbs
  end

  def view_template
    div(class: "page-header") do
      render Views::Components::Breadcrumb.new(items: [
        { label: "Walk & Talk", path: helpers.walk_sessions_path },
        { label: @walk_session.name }
      ])
      div(class: "header-actions") do
        a(href: helpers.edit_walk_session_path(@walk_session), class: "button button--secondary") { "Edit" }
        button_to "Delete", helpers.walk_session_path(@walk_session),
          method: :delete, data: { turbo_confirm: "Delete this session?" },
          class: "button button--danger"
      end
    end

    div(class: "walk-builder") do
      # Left: playlist
      div(class: "walk-playlist") do
        render_playlist
      end

      # Right: item pickers
      div(class: "walk-pickers") do
        render_picker("Conversations", "ConversationExercise", @conversations)
        render_picker("Phrase Cards",  "PhraseCard",           @phrases)
        render_picker("Verb Exercises", "VerbTransformationExercise", @verbs) if @verbs.any?
      end
    end
  end

  private

  def render_playlist
    items = @walk_session.walk_session_items

    h2(class: "walk-section-title") { "Playlist (#{items.count})" }

    div(class: "walk-meta") do
      span { "#{@walk_session.inner_pause_ms / 1000.0}s inner pause · #{@walk_session.outer_pause_ms / 1000.0}s outer pause" }
    end

    if items.empty?
      p(class: "muted walk-empty") { "Add items from the right →" }
    else
      div(class: "walk-items") do
        items.each_with_index do |wsi, idx|
          div(class: "walk-item #{"walk-item--no-audio" unless wsi.has_audio?}") do
            div(class: "walk-item-body") do
              div(class: "walk-item-label") { wsi.label }
              div(class: "walk-item-sub") do
                span(class: "walk-item-type") { wsi.item_type.gsub(/([A-Z])/, ' \1').strip }
                span { " · " }
                plain wsi.sub_label.to_s
                unless wsi.has_audio?
                  span(class: "walk-item-warn") { " · no audio" }
                end
              end
            end
            div(class: "walk-item-actions") do
              if idx > 0
                button_to "↑", helpers.move_up_walk_session_walk_session_item_path(@walk_session, wsi),
                  method: :post, class: "button button--secondary button--sm"
              end
              if idx < items.count - 1
                button_to "↓", helpers.move_down_walk_session_walk_session_item_path(@walk_session, wsi),
                  method: :post, class: "button button--secondary button--sm"
              end
              button_to "✕", helpers.walk_session_walk_session_item_path(@walk_session, wsi),
                method: :delete, class: "button button--danger button--sm"
            end
          end
        end
      end

      div(class: "walk-generate") do
        button_to "Generate audio", helpers.generate_walk_session_path(@walk_session),
          method: :post, class: "button",
          data: { turbo_confirm: "This may take a moment. Generate the walk audio?" }

        if @walk_session.ready? && @walk_session.audio.attached?
          a(href: helpers.audio_walk_session_path(@walk_session), class: "button button--secondary") { "Download MP3" }
        end

        if @walk_session.failed?
          span(class: "walk-status walk-status--failed") { "Last generation failed" }
        end
      end
    end
  end

  def render_picker(title, type, items)
    div(class: "walk-picker") do
      h2(class: "walk-section-title") { title }

      if items.empty?
        p(class: "muted") { "No #{title.downcase} with audio yet." }
      else
        div(class: "walk-picker-list") do
          items.each do |item|
            wsi_temp = WalkSessionItem.new(item: item)
            has_audio = wsi_temp.has_audio?

            div(class: "walk-picker-item #{"walk-picker-item--no-audio" unless has_audio}") do
              div(class: "walk-picker-body") do
                div(class: "walk-picker-label") { wsi_temp.label }
                unless has_audio
                  span(class: "walk-item-warn") { "no audio" }
                end
              end
              form(action: helpers.walk_session_walk_session_items_path(@walk_session),
                   method: "post", data: { turbo: "false" }) do
                input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)
                input(type: "hidden", name: "item_type", value: type)
                input(type: "hidden", name: "item_id",   value: item.id)
                button(type: "submit", class: "button button--secondary button--sm") { "+" }
              end
            end
          end
        end
      end
    end
  end
end
