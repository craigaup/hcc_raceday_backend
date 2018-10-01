class AddCoordinatesToDistances < ActiveRecord::Migration[5.1]
  def change
    add_column :distances, :latitude, :string
    add_column :distances, :longitude, :string
  end
end
