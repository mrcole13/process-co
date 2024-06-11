class RemoveColumnsFromPayments < ActiveRecord::Migration[7.2]
  def change
    remove_column :payments, :property_id, :string
    remove_column :payments, :resident_id, :string
  end
end
