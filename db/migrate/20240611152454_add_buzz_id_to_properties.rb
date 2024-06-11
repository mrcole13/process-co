class AddBuzzIdToProperties < ActiveRecord::Migration[7.2]
  def change
    add_column :properties, :buzz_id, :string
  end
end
