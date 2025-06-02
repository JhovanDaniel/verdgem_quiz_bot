class CreateBadges < ActiveRecord::Migration[7.1]
  def change
    create_table :badges, id: :uuid do |t|
      t.string :name, null: false
      t.text :description

      t.json :conditions, null: false
      t.boolean :active, default: true
      t.string :category, default: "general"
      t.integer :rarity, default: 1 # 1=common, 2=uncommon, 3=rare, 4=epic, 5=legendary
      
      t.timestamps
    end
    add_index :badges, :active
    add_index :badges, :category
    add_index :badges, :rarity
  end
end
