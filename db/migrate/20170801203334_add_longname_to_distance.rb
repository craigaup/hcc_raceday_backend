class AddLongnameToDistance < ActiveRecord::Migration[5.0]
  def change
    add_column :distances, :longname, :string
  end
end
