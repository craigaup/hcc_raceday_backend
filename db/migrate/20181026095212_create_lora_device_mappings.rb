class CreateLoraDeviceMappings < ActiveRecord::Migration[5.1]
  def change
    create_table :lora_device_mappings do |t|
      t.string :device_registration
      t.integer :number

      t.timestamps
    end
  end
end
