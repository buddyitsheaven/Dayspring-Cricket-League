class Admin::QuestionsController < Admin::BaseController
  before_action :set_match

  def new
    @question = @match.prediction_questions.new(point_value: 1)
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

    if @question.update(question_params)
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
    params.require(:prediction_question).permit(:prompt, :point_value, :correct_option_id)
  end

  def build_options(question, labels_text)
    labels = labels_text.to_s.lines.map(&:strip).reject(&:blank?).uniq

    if labels.empty?
      question.errors.add(:base, "Add at least one option.")
      return
    end

    labels.each do |label|
      question.options.build(label: label)
    end
  end
end
