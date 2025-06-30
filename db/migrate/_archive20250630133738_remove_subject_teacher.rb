class RemoveSubjectTeacher < ActiveRecord::Migration[7.1]
  def change
    drop_table :subject_teachers
  end
end
