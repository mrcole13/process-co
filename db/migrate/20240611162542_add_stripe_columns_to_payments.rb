class AddStripeColumnsToPayments < ActiveRecord::Migration[7.2]
  def change
    add_column :payments, :status, :string
    add_column :payments, :payment_link, :string
    add_column :payments, :link_id, :string
    add_column :payments, :is_full_payment, :boolean
  end
end
