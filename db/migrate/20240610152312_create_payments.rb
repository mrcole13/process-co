class CreatePayments < ActiveRecord::Migration[7.2]
  def change
    create_table :payments do |t|
      t.string :property_id
      t.string :amount
      t.string :resident_id

      t.timestamps
    end
  end
end
