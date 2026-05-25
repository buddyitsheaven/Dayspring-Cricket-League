class AddScoringToPredictionOptions < ActiveRecord::Migration[7.1]
  def up
    add_column :prediction_options, :point_value, :integer, null: false, default: 1
    add_column :prediction_options, :penalty_value, :integer, null: false, default: 0

    execute <<~SQL.squish
      UPDATE prediction_options
      SET
        point_value = prediction_questions.point_value,
        penalty_value = prediction_questions.penalty_value
      FROM prediction_questions
      WHERE prediction_questions.id = prediction_options.prediction_question_id
    SQL
  end

  def down
    remove_column :prediction_options, :point_value
    remove_column :prediction_options, :penalty_value
  end
end
