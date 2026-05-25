class AddPenaltyValueToPredictionQuestions < ActiveRecord::Migration[7.1]
  def change
    add_column :prediction_questions, :penalty_value, :integer, null: false, default: 0
  end
end
