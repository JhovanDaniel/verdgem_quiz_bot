class CreateSubTopics < ActiveRecord::Migration[7.1]
  def change
    create_table :sub_topics, id: :uuid do |t|
      
      t.string :name, null: false
      t.text :description
      t.references :topic, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
