class AddDataToLocations < ActiveRecord::Migration[5.1]
  def change
    add_column :locations, :device, :string
    add_column :locations, :lrresp, :string
    add_column :locations, :temperature, :string
    add_column :locations, :altitude, :string
  end
end
