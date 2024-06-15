class AddUnitOccupancyIdColumnToResident < ActiveRecord::Migration[7.2]
  def change
    add_column :residents, :unit_occupancy_id, :string
  end
end
