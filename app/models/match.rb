class Match < ApplicationRecord
  has_many :prediction_questions, dependent: :destroy
  has_many :prediction_submissions, dependent: :destroy

  validates :team_one, :team_two, :starts_at, presence: true

  scope :ordered, -> { order(:starts_at) }
  scope :on_date, ->(date) { where(starts_at: date.beginning_of_day..date.end_of_day).ordered }

  def name
    "#{team_one} vs #{team_two}"
  end

  def locked?
    starts_at <= Time.current
  end
end
