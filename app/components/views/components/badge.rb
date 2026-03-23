# frozen_string_literal: true

# Renders a badge span with an optional BEM variant class.
#
# Usage:
#   render Views::Components::Badge.new(label: "N3")
#   render Views::Components::Badge.new(label: "Added", variant: "success")
#   render Views::Components::Badge.new(label: "Failed", variant: "error")
class Views::Components::Badge < ApplicationView
  def initialize(label:, variant: nil)
    @label   = label
    @variant = variant
  end

  def view_template
    css = @variant ? "badge badge--#{@variant}" : "badge"
    span(class: css) { @label }
  end
end
