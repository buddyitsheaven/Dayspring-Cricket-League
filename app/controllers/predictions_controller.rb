class PredictionsController < ApplicationController
  before_action :authenticate_user!

  def create
    @match = Match.includes(prediction_questions: :options).find(prediction_params[:match_id])
    questions = @match.prediction_questions.to_a
    answers = prediction_params[:answers]&.to_h || {}

    if questions.empty?
      redirect_to root_path(date: @match.starts_at.to_date), alert: "No prediction questions found for this match."
      return
    end

    if questions.any? { |question| answers[question.id.to_s].blank? }
      redirect_to root_path(date: @match.starts_at.to_date), alert: "Select one answer for every question before saving."
      return
    end

    ActiveRecord::Base.transaction do
      questions.each do |question|
        prediction = current_user.predictions.find_or_initialize_by(prediction_question: question)
        action_type = prediction.persisted? ? "updated" : "created"
        prediction.assign_attributes(prediction_option_id: answers[question.id.to_s])
        prediction.save!

        PredictionSubmission.create!(
          user: current_user,
          match: @match,
          prediction_question: question,
          prediction_option: prediction.prediction_option,
          action_type: action_type,
          submitted_at: Time.current
        )
      end
    end

    redirect_to root_path(date: @match.starts_at.to_date), notice: "Your picks have been saved."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to root_path(date: @match.starts_at.to_date), alert: error.record.errors.full_messages.to_sentence
  end

  private

  def prediction_params
    params.require(:prediction).permit(:match_id, answers: {})
  end
end
