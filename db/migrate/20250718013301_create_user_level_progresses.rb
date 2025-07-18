class CreateUserLevelProgresses < ActiveRecord::Migration[7.1]
  def change
    create_table :user_level_progresses, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :level, null: false, foreign_key: true, type: :uuid
      t.integer :attempts, default: 0
      t.boolean :completed, default: false
      t.datetime :completed_at
      t.integer :best_score, default: 0

      t.timestamps
    end
    add_index :user_level_progresses, [:user_id, :level_id], unique: true
  end
end
