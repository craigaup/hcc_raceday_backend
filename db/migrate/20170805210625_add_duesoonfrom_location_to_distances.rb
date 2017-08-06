class AddDuesoonfromLocationToDistances < ActiveRecord::Migration[5.0]
  def change
    add_column :distances, :duesoonfrom, :string
  end
end
