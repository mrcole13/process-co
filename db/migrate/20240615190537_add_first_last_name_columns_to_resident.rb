class AddFirstLastNameColumnsToResident < ActiveRecord::Migration[7.2]
  def change
    add_column :residents, :first_name, :string
    add_column :residents, :last_name, :string
  end
end
