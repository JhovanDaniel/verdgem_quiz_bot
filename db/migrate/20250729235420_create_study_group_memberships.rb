class CreateStudyGroupMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :study_group_memberships, id: :uuid, force: :cascade do |t|
      t.uuid :study_group_id, null: false
      t.uuid :user_id, null: false
      t.integer :role, default: 0 # 0: member, 1: admin, 2: leader
      t.integer :status, default: 0 # 0: pending, 1: active, 2: inactive, 3: banned
      t.datetime :joined_at
      t.datetime :last_active_at
      t.text :join_message
      t.uuid :invited_by_id
      t.integer :points_contributed, default: 0
      t.integer :monthly_points_contributed, default: 0
      t.integer :quizzes_completed_in_group, default: 0
      t.timestamps
      
      t.index [:study_group_id], name: "index_study_group_memberships_on_study_group_id"
      t.index [:user_id], name: "index_study_group_memberships_on_user_id"
      t.index [:role], name: "index_study_group_memberships_on_role"
      t.index [:status], name: "index_study_group_memberships_on_status"
      t.index [:points_contributed], name: "index_study_group_memberships_on_points_contributed"
      t.index [:study_group_id, :user_id], name: "index_study_group_memberships_uniqueness", unique: true
    end
    
    add_foreign_key :study_group_memberships, :study_groups, on_delete: :cascade
    add_foreign_key :study_group_memberships, :users, on_delete: :cascade
    add_foreign_key :study_group_memberships, :users, column: :invited_by_id, on_delete: :nullify
  end
end
