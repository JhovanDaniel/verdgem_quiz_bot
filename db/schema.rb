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

ActiveRecord::Schema[7.1].define(version: 2025_03_23_192313) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "question_attempts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "question_id", null: false
    t.text "student_answer"
    t.integer "score"
    t.text "feedback"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "evaluation_status", default: "pending"
    t.text "evaluation_error"
    t.uuid "quiz_session_id"
    t.index ["question_id"], name: "index_question_attempts_on_question_id"
    t.index ["quiz_session_id"], name: "index_question_attempts_on_quiz_session_id"
    t.index ["user_id"], name: "index_question_attempts_on_user_id"
  end

  create_table "questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "content"
    t.text "model_answer"
    t.text "key_concepts"
    t.text "marking_criteria"
    t.integer "max_points"
    t.integer "difficulty_level"
    t.uuid "topic_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["topic_id"], name: "index_questions_on_topic_id"
  end

  create_table "quiz_sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "subject_id", null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.integer "total_score"
    t.integer "max_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "topic_id"
    t.integer "question_count"
    t.index ["subject_id"], name: "index_quiz_sessions_on_subject_id"
    t.index ["topic_id"], name: "index_quiz_sessions_on_topic_id"
    t.index ["user_id"], name: "index_quiz_sessions_on_user_id"
  end

  create_table "subjects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.text "syllabus_outline"
    t.integer "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "created_by_id"
    t.index ["created_by_id"], name: "index_subjects_on_created_by_id"
  end

  create_table "subscribers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.boolean "subscribed", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_subscribers_on_email", unique: true
  end

  create_table "topics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.uuid "subject_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subject_id"], name: "index_topics_on_subject_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "role", default: 0
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quiz_attempts", default: 0
    t.integer "max_quiz_attempts", default: 30
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "question_attempts", "questions"
  add_foreign_key "question_attempts", "quiz_sessions"
  add_foreign_key "question_attempts", "users"
  add_foreign_key "questions", "topics"
  add_foreign_key "quiz_sessions", "subjects"
  add_foreign_key "quiz_sessions", "topics"
  add_foreign_key "quiz_sessions", "users"
  add_foreign_key "subjects", "users", column: "created_by_id"
  add_foreign_key "topics", "subjects"
end
