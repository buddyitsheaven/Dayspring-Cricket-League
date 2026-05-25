class PredictionQuestion < ApplicationRecord
  belongs_to :match
  belongs_to :correct_option, class_name: "PredictionOption", optional: true

  has_many :options, class_name: "PredictionOption", dependent: :destroy, inverse_of: :prediction_question
  has_many :predictions, dependent: :destroy
  has_many :prediction_submissions, dependent: :destroy

  validates :prompt, presence: true
  validates :point_value, numericality: { greater_than: 0 }
  validates :penalty_value, numericality: { greater_than_or_equal_to: 0 }
  validate :correct_option_belongs_to_question

  def open_for_predictions?
    !match.locked?
  end

  def score_for(option_id)
    return 0 if correct_option_id.blank? || option_id.blank?

    selected_option = options.find_by(id: option_id)
    return 0 if selected_option.blank?

    correct_option_id == option_id ? selected_option.point_value : -selected_option.penalty_value
  end

  private

  def correct_option_belongs_to_question
    return if correct_option.blank? || id.blank?
    return if correct_option.prediction_question_id == id

    errors.add(:correct_option_id, "must belong to this question")
  end
end
