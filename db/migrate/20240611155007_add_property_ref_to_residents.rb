class AddPropertyRefToResidents < ActiveRecord::Migration[7.2]
  def change
    add_reference :residents, :property, null: false, foreign_key: true
  end
end
