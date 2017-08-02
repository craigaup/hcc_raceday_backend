class CreateDistances < ActiveRecord::Migration[5.0]
  def change
    create_table :distances do |t|
      t.integer :year
      t.string :checkpoint
      t.string :distance

      t.timestamps
    end
  end
end
