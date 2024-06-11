class AddPropertyAndResidentRefToPayments < ActiveRecord::Migration[7.2]
  def change
    add_reference :payments, :property, null: false, foreign_key: true
    add_reference :payments, :resident, null: false, foreign_key: true
  end
end
