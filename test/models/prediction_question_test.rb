require "test_helper"

class PredictionQuestionTest < ActiveSupport::TestCase
  test "score_for returns positive points for correct answers" do
    question = prediction_questions(:one)

    assert_equal 1, question.score_for(question.correct_option_id)
  end

  test "score_for returns negative penalty for wrong answers" do
    question = prediction_questions(:one)
    wrong_option = question.options.where.not(id: question.correct_option_id).first

    assert_equal(-1, question.score_for(wrong_option.id))
  end

  test "score_for returns zero when result is not set" do
    question = PredictionQuestion.create!(
      match: matches(:one),
      prompt: "Score bucket",
      point_value: 3,
      penalty_value: 3
    )
    option = question.options.create!(label: "<= 120")

    assert_equal 0, question.score_for(option.id)
  end
end
