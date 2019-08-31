require File.dirname(__FILE__) + '/.lora_devices.rb'

lora_devices = @lora_devices

lora_devices.each_with_index do |element, index|
  dev = LoraDeviceMapping.find_by(id: index + 1)
  if dev.nil?
    puts "Adding device #{element[:device_registration]} as #{element[:number]}"
    LoraDeviceMapping.create(id: index + 1,
                             device_registration: element[:device_registration],
                             number: element[:number])
  else
    updated = false
    if dev.device_registration != element[:device_registration]
      dev.device_registration = element[:device_registration]
      updated = true
    end

    if dev.number != element[:number]
      dev.number = element[:number]
      updated = true
    end

    if updated 
      puts "Updating device #{element[:device_registration]} as #{element[:number]}"
      dev.save
    end
  end
end

LoraDeviceMapping.all.each do |l|
  if l.id == 0 
    puts "Removing device #{l.device_registration}"
    l.destroy
  end

  if lora_devices[l.id - 1].nil?
    puts "Removing device #{l.device_registration}"
    l.destroy
  end
end


