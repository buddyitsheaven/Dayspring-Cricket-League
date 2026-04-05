class LeaderboardsController < ApplicationController
  def index
    @ranked_users = User.ranked_with_scores
  end
end
