class CreateQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :questions, id: :uuid do |t|
      t.text :content
      t.text :model_answer
      t.text :key_concepts
      t.text :marking_criteria
      t.integer :max_points
      t.integer :difficulty_level
      t.references :topic, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
