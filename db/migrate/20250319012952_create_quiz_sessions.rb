class CreateQuizSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :quiz_sessions, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :subject, null: false, foreign_key: true, type: :uuid
      t.references :topic, null: false, foreign_key: true, type: :uuid
      t.datetime :started_at
      t.datetime :completed_at
      t.integer :total_score
      t.integer :max_score

      t.timestamps
    end
  end
end
