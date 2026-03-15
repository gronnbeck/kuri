# frozen_string_literal: true

class Views::Home::Index < ApplicationView
  def view_template
    div(class: "welcome") do
      h1 { "Welcome to Kuri" }
      p { "Your personal vocabulary library." }
    end
  end
end
