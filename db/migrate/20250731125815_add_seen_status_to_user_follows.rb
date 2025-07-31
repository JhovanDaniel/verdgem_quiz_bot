class AddSeenStatusToUserFollows < ActiveRecord::Migration[7.1]
  def change
    add_column :user_follows, :new_follow, :boolean, default: true
  end
end
