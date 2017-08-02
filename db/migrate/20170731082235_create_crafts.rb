class CreateCrafts < ActiveRecord::Migration[5.0]
  def change
    create_table :crafts do |t|
      t.integer :number
      t.integer :year
      t.string :status
      t.datetime :time
      t.datetime :entered
      t.belongs_to :user, foreign_key: true
      t.references :checkpoint, foreign_key: {to_table: :distances}

      t.timestamps
    end
  end
end
