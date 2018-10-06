class CreateLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :locations do |t|
      t.integer :number
      t.string :latitude
      t.string :longitude
      t.datetime :time

      t.timestamps
    end
  end
end
