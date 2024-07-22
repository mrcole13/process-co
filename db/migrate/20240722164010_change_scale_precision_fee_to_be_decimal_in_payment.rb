class ChangeScalePrecisionFeeToBeDecimalInPayment < ActiveRecord::Migration[7.2]
  def change
    change_column :payments, :fee, :decimal, :precision => 8, :scale => 2
  end
end
