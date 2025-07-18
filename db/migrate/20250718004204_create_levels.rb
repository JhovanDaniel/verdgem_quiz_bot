class CreateLevels < ActiveRecord::Migration[7.1]
  def change
    create_table :levels, id: :uuid do |t|
      t.references :world, null: false, foreign_key: true, type: :uuid
      t.references :sub_topic, null: false, foreign_key: true, type: :uuid
      t.references :prerequisite_level, null: true, foreign_key: { to_table: :levels }, type: :uuid
      
      t.string :name, null: false
      t.text :description
      t.string :difficulty, null: false
      t.integer :position, null: false
      t.integer :question_type, default: 0
      t.integer :question_count, default: 15
      t.integer :passing_score_percentage, default: 70
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
