class CreateFeedbacks < ActiveRecord::Migration[7.1]
  def change
    create_table :feedbacks, id: :uuid do |t|
      t.references :quiz_session, null: false, foreign_key: true, type: :uuid
      t.integer :rating
      t.text :comment

      t.timestamps
    end
  end
end
