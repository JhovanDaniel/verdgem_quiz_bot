class AddInstitutionToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :institution, foreign_key: true, type: :uuid
  end
end
