class CreateData < ActiveRecord::Migration[5.0]
  def change
    create_table :data do |t|
      t.string :key
      t.string :data
      t.datetime :time
      t.belongs_to :user, foreign_key: true
      t.integer :year

      t.timestamps
    end
  end
end
