class PredictionOption < ApplicationRecord
  belongs_to :prediction_question
  has_many :predictions, dependent: :restrict_with_error
  has_many :prediction_submissions, dependent: :restrict_with_error

  validates :label, presence: true
  validates :point_value, numericality: { greater_than: 0 }
  validates :penalty_value, numericality: { greater_than_or_equal_to: 0 }
end
