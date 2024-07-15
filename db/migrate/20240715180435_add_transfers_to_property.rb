class AddTransfersToProperty < ActiveRecord::Migration[7.2]
  def change
    add_column :properties, :transfers, :string
  end
end
