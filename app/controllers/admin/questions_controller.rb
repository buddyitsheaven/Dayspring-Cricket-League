class Admin::QuestionsController < Admin::BaseController
  before_action :set_match

  def new
    @question = @match.prediction_questions.new(point_value: 1, penalty_value: 0)
  end

  def edit
    @question = @match.prediction_questions.find(params[:id])
  end

  def create
    @question = @match.prediction_questions.new(question_params)
    build_options(@question, params[:prediction_question][:option_labels])

    if @question.errors.empty? && @question.save
      redirect_to edit_admin_match_path(@match), notice: "Question created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @question = @match.prediction_questions.find(params[:id])
    sync_option_scores = @question.options.all? do |option|
      option.point_value == @question.point_value && option.penalty_value == @question.penalty_value
    end

    if @question.update(question_params)
      if sync_option_scores && (@question.saved_change_to_point_value? || @question.saved_change_to_penalty_value?)
        @question.options.update_all(point_value: @question.point_value, penalty_value: @question.penalty_value)
      end

      redirect_to edit_admin_match_path(@match), notice: "Question updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_match
    @match = Match.find(params[:match_id])
  end

  def question_params
    params.require(:prediction_question).permit(:prompt, :point_value, :penalty_value, :correct_option_id)
  end

  def build_options(question, labels_text)
    labels = labels_text.to_s.lines.map(&:strip).reject(&:blank?).uniq

    if labels.empty?
      question.errors.add(:base, "Add at least one option.")
      return
    end

    labels.each do |label|
      option_attrs = parse_option_attributes(label, question)
      next if option_attrs.blank?

      question.options.build(option_attrs)
    end
  end

  def parse_option_attributes(line, question)
    raw_label, raw_points, raw_penalty = line.split("|", 3).map(&:strip)

    if raw_label.blank?
      question.errors.add(:base, "Each option needs a label.")
      return
    end

    point_value = parse_integer(raw_points, question.point_value)
    penalty_value = parse_integer(raw_penalty, question.penalty_value)

    if point_value.blank? || point_value <= 0
      question.errors.add(:base, "Option #{raw_label} must have a valid positive point value.")
      return
    end

    if penalty_value.blank? || penalty_value.negative?
      question.errors.add(:base, "Option #{raw_label} must have a valid penalty value.")
      return
    end

    {
      label: raw_label,
      point_value: point_value,
      penalty_value: penalty_value
    }
  end

  def parse_integer(value, fallback)
    return fallback if value.blank?

    Integer(value, 10)
  rescue ArgumentError
    nil
  end
end
