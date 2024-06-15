class AddEmailColumnToResident < ActiveRecord::Migration[7.2]
  def change
    add_column :residents, :email, :string
  end
end
