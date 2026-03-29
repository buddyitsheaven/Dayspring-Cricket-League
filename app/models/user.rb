class User < ApplicationRecord
  ALLOWED_EMAIL_DOMAINS = %w[dayspringlabs.com dayspring.tech].freeze

  has_secure_password

  has_many :predictions, dependent: :destroy
  has_many :prediction_submissions, dependent: :destroy

  before_validation :normalize_email

  validates :email, presence: true, uniqueness: true
  validate :email_domain_must_be_allowed

  def score
    predictions.includes(:prediction_question).sum do |prediction|
      prediction.correct? ? prediction.prediction_question.point_value : 0
    end
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end

  def email_domain_must_be_allowed
    domain = email.to_s.split("@").last
    return if ALLOWED_EMAIL_DOMAINS.include?(domain)

    errors.add(:email, "must use @dayspringlabs.com or @dayspring.tech")
  end
end
