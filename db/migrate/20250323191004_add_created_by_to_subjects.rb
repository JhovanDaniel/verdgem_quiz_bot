class AddCreatedByToSubjects < ActiveRecord::Migration[7.1]
  def change
    add_reference :subjects, :created_by, foreign_key: { to_table: :users }, null: true, type: :uuid
  end
end
