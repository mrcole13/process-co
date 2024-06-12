class AddPropertyManagerToProperty < ActiveRecord::Migration[7.2]
  def change
    add_column :properties, :property_manager_id, :integer, null: true
    add_foreign_key :properties, :properties, column: :property_manager_id
  end
end
