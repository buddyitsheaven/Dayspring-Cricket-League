class DashboardController < ApplicationController
  DATES_PER_PAGE = 6

  def index
    @available_dates = Match.ordered.map { |match| match.starts_at.to_date }.uniq
    @selected_date = selected_date
    @total_schedule_pages = @available_dates.any? ? (@available_dates.size.to_f / DATES_PER_PAGE).ceil : 0
    @schedule_page = @available_dates.any? ? [[schedule_page, 1].max, @total_schedule_pages].min : 0
    @visible_dates = @available_dates.any? ? (@available_dates.slice((@schedule_page - 1) * DATES_PER_PAGE, DATES_PER_PAGE) || []) : []
    @matches = Match.on_date(@selected_date).includes(prediction_questions: :options)
    @predictions_by_question_id = {}
    @ranked_users = User.all.sort_by { |user| [-user.score, user.email] }.first(3)

    return unless current_user

    question_ids = @matches.flat_map { |match| match.prediction_questions.map(&:id) }
    @predictions_by_question_id = current_user.predictions.where(prediction_question_id: question_ids).index_by(&:prediction_question_id)
    @answered_questions_count = @predictions_by_question_id.size
    @daily_points = current_user.predictions.includes(:prediction_question).select do |prediction|
      prediction.prediction_question.match.starts_at.to_date == @selected_date && prediction.correct?
    end.sum { |prediction| prediction.prediction_question.point_value }
  end

  private

  def selected_date
    return parsed_date if parsed_date.present?
    return Date.current if @available_dates.blank? && params[:date].blank?

    @available_dates.find { |date| date >= Date.current } || @available_dates.first || Date.current
  end

  def parsed_date
    Date.parse(params[:date]) if params[:date].present?
  rescue ArgumentError
    nil
  end

  def schedule_page
    return params[:page].to_i if params[:page].present?

    selected_index = @available_dates.index(@selected_date) || 0
    (selected_index / DATES_PER_PAGE) + 1
  end
end
