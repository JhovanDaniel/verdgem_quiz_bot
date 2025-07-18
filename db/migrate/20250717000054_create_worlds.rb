class CreateWorlds < ActiveRecord::Migration[7.1]
  def change
    create_table :worlds, id: :uuid do |t|
      t.string :name, null: false
      t.text :description
      t.references :subject, null: false, foreign_key: true, type: :uuid
      t.boolean :is_active, default: true
      
      t.timestamps
    end
    add_index :worlds, :name
  end
end
