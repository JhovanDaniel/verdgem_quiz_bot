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

ActiveRecord::Schema[7.1].define(version: 2025_08_04_135039) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "answer_options", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "question_id", null: false
    t.text "content", null: false
    t.boolean "is_correct", default: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_answer_options_on_question_id"
  end

  create_table "badges", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.json "conditions", null: false
    t.boolean "active", default: true
    t.string "category", default: "general"
    t.integer "rarity", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_badges_on_active"
    t.index ["category"], name: "index_badges_on_category"
    t.index ["rarity"], name: "index_badges_on_rarity"
  end

  create_table "feedbacks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "quiz_session_id", null: false
    t.integer "rating"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.index ["quiz_session_id"], name: "index_feedbacks_on_quiz_session_id"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "institutions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.boolean "active", default: true
    t.string "contact_email"
    t.string "phone"
    t.text "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "country"
    t.index ["active"], name: "index_institutions_on_active"
    t.index ["name"], name: "index_institutions_on_name", unique: true
  end

  create_table "levels", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "world_id", null: false
    t.uuid "sub_topic_id", null: false
    t.uuid "prerequisite_level_id"
    t.string "name", null: false
    t.text "description"
    t.integer "position", null: false
    t.integer "question_type", default: 0
    t.integer "question_count", default: 15
    t.integer "passing_score_percentage", default: 70
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "difficulty"
    t.index ["prerequisite_level_id"], name: "index_levels_on_prerequisite_level_id"
    t.index ["sub_topic_id"], name: "index_levels_on_sub_topic_id"
    t.index ["world_id"], name: "index_levels_on_world_id"
  end

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
    t.boolean "has_problem", default: false
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
    t.integer "question_type", default: 0
    t.uuid "sub_topic_id"
    t.index ["sub_topic_id"], name: "index_questions_on_sub_topic_id"
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
    t.text "question_ids"
    t.boolean "archived", default: false
    t.uuid "sub_topic_id"
    t.uuid "level_id"
    t.index ["level_id"], name: "index_quiz_sessions_on_level_id"
    t.index ["sub_topic_id"], name: "index_quiz_sessions_on_sub_topic_id"
    t.index ["subject_id"], name: "index_quiz_sessions_on_subject_id"
    t.index ["topic_id"], name: "index_quiz_sessions_on_topic_id"
    t.index ["user_id"], name: "index_quiz_sessions_on_user_id"
  end

  create_table "study_group_invitations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "study_group_id", null: false
    t.uuid "inviter_id", null: false
    t.uuid "invitee_id", null: false
    t.integer "status", default: 0
    t.text "message"
    t.datetime "expires_at"
    t.datetime "responded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "new_invitation", default: true
    t.index ["expires_at"], name: "index_study_group_invitations_on_expires_at"
    t.index ["invitee_id"], name: "index_study_group_invitations_on_invitee_id"
    t.index ["inviter_id"], name: "index_study_group_invitations_on_inviter_id"
    t.index ["status"], name: "index_study_group_invitations_on_status"
    t.index ["study_group_id", "invitee_id"], name: "index_study_group_invitations_uniqueness", unique: true
    t.index ["study_group_id"], name: "index_study_group_invitations_on_study_group_id"
  end

  create_table "study_group_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "study_group_id", null: false
    t.uuid "user_id", null: false
    t.integer "role", default: 0
    t.integer "status", default: 0
    t.datetime "joined_at"
    t.datetime "last_active_at"
    t.text "join_message"
    t.uuid "invited_by_id"
    t.integer "points_contributed", default: 0
    t.integer "monthly_points_contributed", default: 0
    t.integer "quizzes_completed_in_group", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["points_contributed"], name: "index_study_group_memberships_on_points_contributed"
    t.index ["role"], name: "index_study_group_memberships_on_role"
    t.index ["status"], name: "index_study_group_memberships_on_status"
    t.index ["study_group_id"], name: "index_study_group_memberships_on_study_group_id"
    t.index ["user_id"], name: "index_study_group_memberships_on_user_id"
    t.index ["user_id"], name: "index_study_group_memberships_unique_active_user", unique: true, where: "(status = 0)"
  end

  create_table "study_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.uuid "created_by_id", null: false
    t.boolean "is_active", default: true
    t.text "clan_motto"
    t.string "clan_color", default: "#3b82f6"
    t.integer "total_points", default: 0
    t.integer "monthly_points", default: 0
    t.datetime "last_points_reset_at"
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_study_groups_on_created_by_id"
    t.index ["is_active"], name: "index_study_groups_on_is_active"
    t.index ["monthly_points"], name: "index_study_groups_on_monthly_points"
    t.index ["name"], name: "index_study_groups_on_name"
    t.index ["total_points"], name: "index_study_groups_on_total_points"
  end

  create_table "sub_topics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.uuid "topic_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["topic_id"], name: "index_sub_topics_on_topic_id"
  end

  create_table "subject_teachers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "subject_id", null: false
    t.uuid "user_id", null: false
    t.boolean "active", default: true
    t.datetime "assigned_at", default: -> { "CURRENT_TIMESTAMP" }
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_subject_teachers_on_active"
    t.index ["assigned_at"], name: "index_subject_teachers_on_assigned_at"
    t.index ["subject_id", "user_id"], name: "index_subject_teachers_on_subject_id_and_user_id", unique: true
    t.index ["subject_id"], name: "index_subject_teachers_on_subject_id"
    t.index ["user_id"], name: "index_subject_teachers_on_user_id"
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

  create_table "user_badges", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "badge_id", null: false
    t.datetime "earned_at", null: false
    t.boolean "featured", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["badge_id"], name: "index_user_badges_on_badge_id"
    t.index ["earned_at"], name: "index_user_badges_on_earned_at"
    t.index ["featured"], name: "index_user_badges_on_featured"
    t.index ["user_id", "badge_id"], name: "index_user_badges_on_user_id_and_badge_id", unique: true
    t.index ["user_id"], name: "index_user_badges_on_user_id"
  end

  create_table "user_follows", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "follower_id", null: false
    t.uuid "followee_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "new_follow", default: true
    t.index ["followee_id"], name: "index_user_follows_on_followee_id"
    t.index ["follower_id", "followee_id"], name: "index_user_follows_on_follower_and_followee", unique: true
    t.index ["follower_id"], name: "index_user_follows_on_follower_id"
  end

  create_table "user_level_progresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "level_id", null: false
    t.integer "attempts", default: 0
    t.boolean "completed", default: false
    t.datetime "completed_at"
    t.integer "best_score", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["level_id"], name: "index_user_level_progresses_on_level_id"
    t.index ["user_id", "level_id"], name: "index_user_level_progresses_on_user_id_and_level_id", unique: true
    t.index ["user_id"], name: "index_user_level_progresses_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "re_member_created_at"
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
    t.string "country"
    t.string "nickname"
    t.uuid "institution_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["institution_id"], name: "index_users_on_institution_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "worlds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.uuid "subject_id", null: false
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_worlds_on_name"
    t.index ["subject_id"], name: "index_worlds_on_subject_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "answer_options", "questions"
  add_foreign_key "feedbacks", "quiz_sessions"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "levels", "levels", column: "prerequisite_level_id"
  add_foreign_key "levels", "sub_topics"
  add_foreign_key "levels", "worlds"
  add_foreign_key "question_attempts", "questions"
  add_foreign_key "question_attempts", "quiz_sessions"
  add_foreign_key "question_attempts", "users", on_delete: :cascade
  add_foreign_key "questions", "sub_topics"
  add_foreign_key "questions", "topics"
  add_foreign_key "quiz_sessions", "levels"
  add_foreign_key "quiz_sessions", "sub_topics"
  add_foreign_key "quiz_sessions", "subjects"
  add_foreign_key "quiz_sessions", "topics"
  add_foreign_key "quiz_sessions", "users", on_delete: :cascade
  add_foreign_key "study_group_invitations", "study_groups", on_delete: :cascade
  add_foreign_key "study_group_invitations", "users", column: "invitee_id", on_delete: :cascade
  add_foreign_key "study_group_invitations", "users", column: "inviter_id", on_delete: :cascade
  add_foreign_key "study_group_memberships", "study_groups", on_delete: :cascade
  add_foreign_key "study_group_memberships", "users", column: "invited_by_id", on_delete: :nullify
  add_foreign_key "study_group_memberships", "users", on_delete: :cascade
  add_foreign_key "study_groups", "users", column: "created_by_id", on_delete: :cascade
  add_foreign_key "sub_topics", "topics"
  add_foreign_key "subject_teachers", "subjects"
  add_foreign_key "subject_teachers", "users"
  add_foreign_key "subjects", "users", column: "created_by_id"
  add_foreign_key "topics", "subjects"
  add_foreign_key "user_badges", "badges"
  add_foreign_key "user_badges", "users"
  add_foreign_key "user_follows", "users", column: "followee_id", on_delete: :cascade
  add_foreign_key "user_follows", "users", column: "follower_id", on_delete: :cascade
  add_foreign_key "user_level_progresses", "levels"
  add_foreign_key "user_level_progresses", "users"
  add_foreign_key "users", "institutions"
  add_foreign_key "worlds", "subjects"
end
