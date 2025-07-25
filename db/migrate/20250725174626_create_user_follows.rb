class CreateUserFollows < ActiveRecord::Migration[7.1]
  def change
    create_table :user_follows, id: :uuid do |t|
      t.uuid :follower_id, null: false
      t.uuid :followee_id, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      
      t.index [:follower_id], name: "index_user_follows_on_follower_id"
      t.index [:followee_id], name: "index_user_follows_on_followee_id"
      t.index [:follower_id, :followee_id], name: "index_user_follows_on_follower_and_followee", unique: true
    end
    
    add_foreign_key :user_follows, :users, column: :follower_id, on_delete: :cascade
    add_foreign_key :user_follows, :users, column: :followee_id, on_delete: :cascade
  end
end
