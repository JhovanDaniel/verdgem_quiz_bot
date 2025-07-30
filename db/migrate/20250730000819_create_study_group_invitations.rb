class CreateStudyGroupInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :study_group_invitations, id: :uuid do |t|
      t.uuid :study_group_id, null: false
      t.uuid :inviter_id, null: false
      t.uuid :invitee_id, null: false
      t.integer :status, default: 0 # 0: pending, 1: accepted, 2: declined, 3: expired
      t.text :message
      t.datetime :expires_at
      t.datetime :responded_at
      t.timestamps
      
      t.index [:study_group_id], name: "index_study_group_invitations_on_study_group_id"
      t.index [:inviter_id], name: "index_study_group_invitations_on_inviter_id"
      t.index [:invitee_id], name: "index_study_group_invitations_on_invitee_id"
      t.index [:status], name: "index_study_group_invitations_on_status"
      t.index [:expires_at], name: "index_study_group_invitations_on_expires_at"
      t.index [:study_group_id, :invitee_id], name: "index_study_group_invitations_uniqueness", unique: true
    end
    
    add_foreign_key :study_group_invitations, :study_groups, on_delete: :cascade
    add_foreign_key :study_group_invitations, :users, column: :inviter_id, on_delete: :cascade
    add_foreign_key :study_group_invitations, :users, column: :invitee_id, on_delete: :cascade
  end
end
