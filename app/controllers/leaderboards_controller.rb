class LeaderboardsController < ApplicationController
  def index
    @ranked_users = User.all.sort_by { |user| [-user.score, user.email] }
  end
end
