class CreateResidents < ActiveRecord::Migration[7.2]
  def change
    create_table :residents do |t|

      t.timestamps
    end
  end
end
