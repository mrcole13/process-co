class ChangeFeeToBeDecimalInPayment < ActiveRecord::Migration[7.2]
  def change
    change_column :payments, :fee, :decimal
  end
end
