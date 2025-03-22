class CreateSubscribers < ActiveRecord::Migration[7.1]
  def change
    create_table :subscribers, id: :uuid do |t|
      t.string :email, null: false
      t.boolean :subscribed, default: true

      t.timestamps
    end
    add_index :subscribers, :email, unique: true
  end
end
