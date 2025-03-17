class CreateSubjects < ActiveRecord::Migration[7.1]
  def change
    create_table :subjects, id: :uuid do |t|
      t.string :name
      t.text :description
      t.text :syllabus_outline
      t.integer :category

      t.timestamps
    end
  end
end
