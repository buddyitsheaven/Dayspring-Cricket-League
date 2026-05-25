require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "score includes penalties for wrong answers after results are set" do
    user = users(:one)

    assert_equal(-1, User.score_for(user.id))
  end

  test "score remains positive for correct answers" do
    user = users(:two)

    assert_equal 1, User.score_for(user.id)
  end
end
