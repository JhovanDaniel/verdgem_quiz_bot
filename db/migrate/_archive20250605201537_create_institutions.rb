class CreateInstitutions < ActiveRecord::Migration[7.1]
  def change
    create_table :institutions do |t|
      t.string :name, null: false
      t.boolean :active, default: true
      t.string :contact_email
      t.string :phone
      t.text :address
      
      t.timestamps
    end
    
    add_index :institutions, :name, unique: true
    add_index :institutions, :active
  end
end
