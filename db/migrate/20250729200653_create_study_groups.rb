class CreateStudyGroups < ActiveRecord::Migration[7.1]
  def change
    create_table :study_groups, id: :uuid, force: :cascade do |t|
      t.string :name, null: false
      t.text :description
      t.uuid :created_by_id, null: false
      t.boolean :is_active, default: true
      t.text :clan_motto
      t.string :clan_color, default: '#3b82f6'
      t.integer :total_points, default: 0
      t.integer :monthly_points, default: 0
      t.datetime :last_points_reset_at
      t.datetime :archived_at

      t.index [:created_by_id], name: "index_study_groups_on_created_by_id"
      t.index [:is_active], name: "index_study_groups_on_is_active"
      t.index [:name], name: "index_study_groups_on_name"
      t.index [:total_points], name: "index_study_groups_on_total_points"
      t.index [:monthly_points], name: "index_study_groups_on_monthly_points"

      t.timestamps
    end
    add_foreign_key :study_groups, :users, column: :created_by_id, on_delete: :cascade
  end
end
