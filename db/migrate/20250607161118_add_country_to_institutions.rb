class AddCountryToInstitutions < ActiveRecord::Migration[7.1]
  def change
    add_column :institutions, :country, :string
  end
end
