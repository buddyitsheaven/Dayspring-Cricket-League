class CommunityVotesController < ApplicationController
  def index
    @available_dates = Match.ordered.map { |match| match.starts_at.to_date }.uniq
    @selected_date = selected_date
    @matches = Match.on_date(@selected_date).includes(prediction_questions: :options)

    question_ids = @matches.flat_map { |match| match.prediction_questions.map(&:id) }
    @vote_counts_by_question = Prediction
      .where(prediction_question_id: question_ids)
      .group(:prediction_question_id, :prediction_option_id)
      .count
      .each_with_object(Hash.new { |hash, key| hash[key] = {} }) do |((question_id, option_id), count), hash|
        hash[question_id][option_id] = count
      end
  end

  def show
    @match = Match.includes(prediction_questions: [:options, { predictions: :user }]).find(params[:id])
    @selected_date = @match.starts_at.to_date
  end

  private

  def selected_date
    parsed_date || @available_dates.find { |date| date >= Date.current } || @available_dates.first || Date.current
  end

  def parsed_date
    Date.parse(params[:date]) if params[:date].present?
  rescue ArgumentError
    nil
  end
end
