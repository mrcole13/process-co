class AddFeeColumnToPayment < ActiveRecord::Migration[7.2]
  def change
    add_column :payments, :fee, :integer
  end
end
