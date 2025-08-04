class AddNewInvitationToStudyGroupInvitation < ActiveRecord::Migration[7.1]
  def change
    add_column :study_group_invitations, :new_invitation, :boolean, default: true
  end
end
