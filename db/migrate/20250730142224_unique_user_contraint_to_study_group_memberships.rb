class UniqueUserContraintToStudyGroupMemberships < ActiveRecord::Migration[7.1]
  def change
    # Remove the existing composite unique index
    remove_index :study_group_memberships, name: "index_study_group_memberships_uniqueness"
    
    # Add unique constraint on user_id for active memberships only
    # This allows users to have only ONE active membership at a time
    add_index :study_group_memberships, :user_id, 
              unique: true, 
              where: "status = 0", # 0 = active status
              name: "index_study_group_memberships_unique_active_user"
  end
end
