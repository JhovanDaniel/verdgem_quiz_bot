class CreateSubjectTeachers < ActiveRecord::Migration[7.1]
  def change
    create_table :subject_teachers, id: :uuid do |t|
      t.references :subject, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.boolean :active, default: true
      t.datetime :assigned_at, default: -> { 'CURRENT_TIMESTAMP' }
      t.text :notes # Optional: for assignment notes
      
      t.timestamps
    end
    
    # Ensure a teacher can't be assigned to the same subject twice
    add_index :subject_teachers, [:subject_id, :user_id], unique: true
    add_index :subject_teachers, :active
    add_index :subject_teachers, :assigned_at
  end
end
