# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_03_27_150000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "matches", force: :cascade do |t|
    t.string "team_one", null: false
    t.string "team_two", null: false
    t.string "venue"
    t.datetime "starts_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["starts_at"], name: "index_matches_on_starts_at"
  end

  create_table "prediction_options", force: :cascade do |t|
    t.bigint "prediction_question_id", null: false
    t.string "label", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prediction_question_id"], name: "index_prediction_options_on_prediction_question_id"
  end

  create_table "prediction_questions", force: :cascade do |t|
    t.bigint "match_id", null: false
    t.string "prompt", null: false
    t.integer "point_value", default: 1, null: false
    t.bigint "correct_option_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["correct_option_id"], name: "index_prediction_questions_on_correct_option_id"
    t.index ["match_id"], name: "index_prediction_questions_on_match_id"
  end

  create_table "prediction_submissions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "match_id", null: false
    t.bigint "prediction_question_id", null: false
    t.bigint "prediction_option_id", null: false
    t.string "action_type", null: false
    t.datetime "submitted_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_prediction_submissions_on_match_id"
    t.index ["prediction_option_id"], name: "index_prediction_submissions_on_prediction_option_id"
    t.index ["prediction_question_id"], name: "index_prediction_submissions_on_prediction_question_id"
    t.index ["submitted_at"], name: "index_prediction_submissions_on_submitted_at"
    t.index ["user_id"], name: "index_prediction_submissions_on_user_id"
  end

  create_table "predictions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "prediction_question_id", null: false
    t.bigint "prediction_option_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prediction_option_id"], name: "index_predictions_on_prediction_option_id"
    t.index ["prediction_question_id"], name: "index_predictions_on_prediction_question_id"
    t.index ["user_id", "prediction_question_id"], name: "index_predictions_on_user_id_and_prediction_question_id", unique: true
    t.index ["user_id"], name: "index_predictions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "prediction_options", "prediction_questions"
  add_foreign_key "prediction_questions", "matches"
  add_foreign_key "prediction_questions", "prediction_options", column: "correct_option_id"
  add_foreign_key "prediction_submissions", "matches"
  add_foreign_key "prediction_submissions", "prediction_options"
  add_foreign_key "prediction_submissions", "prediction_questions"
  add_foreign_key "prediction_submissions", "users"
  add_foreign_key "predictions", "prediction_options"
  add_foreign_key "predictions", "prediction_questions"
  add_foreign_key "predictions", "users"
end
