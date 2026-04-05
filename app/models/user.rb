class User < ApplicationRecord
  ALLOWED_EMAIL_DOMAINS = %w[dayspringlabs.com dayspring.tech].freeze
  LEADERBOARD_SCORE_SQL = <<~SQL.squish.freeze
    COALESCE(
      SUM(
        CASE
          WHEN prediction_questions.correct_option_id IS NOT NULL
           AND predictions.prediction_option_id = prediction_questions.correct_option_id
          THEN prediction_questions.point_value
          ELSE 0
        END
      ),
      0
    )
  SQL
  VOTED_TILL_TODAY_SQL = <<~SQL.squish.freeze
    COALESCE(
      COUNT(
        CASE
          WHEN matches.starts_at::date <= CURRENT_DATE
          THEN predictions.id
        END
      ),
      0
    )
  SQL

  has_secure_password

  has_many :predictions, dependent: :destroy
  has_many :prediction_submissions, dependent: :destroy

  before_validation :normalize_email

  validates :email, presence: true, uniqueness: true
  validate :email_domain_must_be_allowed

  def score
    self[:leaderboard_score] || self.class.score_for(id)
  end

  def leaderboard_score
    score.to_i
  end

  def voted_count
    self[:voted_count].to_i
  end

  def self.ranked_with_scores
    left_joins(predictions: { prediction_question: :match })
      .select("users.*", "#{LEADERBOARD_SCORE_SQL} AS leaderboard_score", "#{VOTED_TILL_TODAY_SQL} AS voted_count")
      .group("users.id")
      .order(Arel.sql("leaderboard_score DESC"), :email)
  end

  def self.top_ranked_with_scores(limit_count = 3)
    ranked_with_scores.limit(limit_count)
  end

  def self.score_for(user_id)
    ranked_with_scores.find(user_id).leaderboard_score.to_i
  end

  def self.rank_for(user_id)
    score_sql = left_joins(predictions: :prediction_question)
      .select(
        "users.id AS user_id",
        "users.email AS user_email",
        "#{LEADERBOARD_SCORE_SQL} AS leaderboard_score"
      )
      .group("users.id", "users.email")
      .to_sql

    ranked_sql = <<~SQL.squish
      SELECT
        score_rows.user_id,
        ROW_NUMBER() OVER (ORDER BY score_rows.leaderboard_score DESC, score_rows.user_email ASC) AS rank_position
      FROM (#{score_sql}) score_rows
    SQL

    result = connection.select_one(<<~SQL.squish)
      SELECT rank_position
      FROM (#{ranked_sql}) ranked_users
      WHERE ranked_users.user_id = #{connection.quote(user_id)}
      LIMIT 1
    SQL

    result&.fetch("rank_position", nil).to_i
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
