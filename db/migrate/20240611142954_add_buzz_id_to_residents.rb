class AddBuzzIdToResidents < ActiveRecord::Migration[7.2]
  def change
    add_column :residents, :buzz_id, :string
  end
end
