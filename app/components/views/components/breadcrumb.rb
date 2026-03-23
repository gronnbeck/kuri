# frozen_string_literal: true

# Renders a breadcrumb nav inside a div.breadcrumb.
#
# Usage:
#   render Views::Components::Breadcrumb.new(items: [
#     { label: "Settings", path: helpers.settings_path },
#     { label: "Listen",   path: helpers.settings_listen_path },
#     { label: "Actors" }   # no path = current page (plain span)
#   ])
class Views::Components::Breadcrumb < ApplicationView
  def initialize(items:)
    @items = items
  end

  def view_template
    div(class: "breadcrumb") do
      @items.each_with_index do |item, i|
        span { " › " } if i > 0
        if item[:path]
          link_to item[:label], item[:path]
        else
          span { item[:label] }
        end
      end
    end
  end
end
