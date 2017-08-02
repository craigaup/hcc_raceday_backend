class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
      t.integer :number
      t.string :to
      t.string :from
      t.datetime :message_time
      t.integer :priority
      t.string :message
      t.time :displayed
      t.datetime :validtil
      t.belongs_to :user, foreign_key: true
      t.datetime :entered
      t.integer :year

      t.timestamps
    end
  end
end
