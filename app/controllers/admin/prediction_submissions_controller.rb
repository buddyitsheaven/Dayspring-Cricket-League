class Admin::PredictionSubmissionsController < Admin::BaseController
  def index
    @prediction_submissions = PredictionSubmission.includes(
      :user,
      :match,
      :prediction_question,
      :prediction_option
    ).order(submitted_at: :desc)
  end
end
