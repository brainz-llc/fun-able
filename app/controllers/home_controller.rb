class HomeController < ApplicationController
  def index
    @recent_games = Game.joinable.recent.limit(5) if logged_in?
  end
end
