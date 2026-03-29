class PredictionSubmission < ApplicationRecord
  belongs_to :user
  belongs_to :match
  belongs_to :prediction_question
  belongs_to :prediction_option

  validates :action_type, :submitted_at, presence: true
end
