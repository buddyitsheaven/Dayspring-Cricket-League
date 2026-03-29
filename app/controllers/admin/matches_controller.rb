class Admin::MatchesController < Admin::BaseController
  def index
    @matches = Match.ordered.includes(:prediction_questions)
  end

  def new
    @match = Match.new
  end

  def edit
    @match = Match.find(params[:id])
  end

  def create
    @match = Match.new(match_params)

    if @match.save
      redirect_to edit_admin_match_path(@match), notice: "Match created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @match = Match.find(params[:id])

    if @match.update(match_params)
      redirect_to edit_admin_match_path(@match), notice: "Match updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def match_params
    params.require(:match).permit(:team_one, :team_two, :venue, :starts_at)
  end
end
