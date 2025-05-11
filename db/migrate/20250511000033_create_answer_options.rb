class CreateAnswerOptions < ActiveRecord::Migration[7.1]
  def change
    create_table :answer_options, id: :uuid do |t|
      t.references :question, null: false, foreign_key: true, type: :uuid
      t.text :content, null: false
      t.boolean :is_correct, default: false
      t.integer :position

      t.timestamps
    end
  end
end
