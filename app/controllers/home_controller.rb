# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    render ::Views::Home::Index.new
  end
end
