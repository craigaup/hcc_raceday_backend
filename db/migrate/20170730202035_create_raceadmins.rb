class CreateRaceadmins < ActiveRecord::Migration[5.0]
  def change
    create_table :raceadmins do |t|
      t.integer :year
      t.belongs_to :user, foreign_key: true

      t.timestamps
    end
  end
end
