class CreateUserBadges < ActiveRecord::Migration[7.1]
  def change
    create_table :user_badges, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :badge, null: false, foreign_key: true, type: :uuid
      t.datetime :earned_at, null: false
      t.boolean :featured, default: false # User can feature badges on profile

      t.timestamps
    end
    
    add_index :user_badges, [:user_id, :badge_id], unique: true
    add_index :user_badges, :earned_at
    add_index :user_badges, :featured
  end
end
