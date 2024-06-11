class AddFeeColumnToProperties < ActiveRecord::Migration[7.2]
  def change
    add_column :properties, :fee_percentage, :string
  end
end
