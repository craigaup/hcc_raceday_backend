class Api::V2018::LoraController < Api::V2018::ApplicationController
  def sendData
    f = Tempfile.new('log', File.join(Rails.root, 'lora'))
    f.write(request.raw_post)
    f.close
    ObjectSpace.undefine_finalizer(f)

    data = JSON.parse(request.raw_post)["DevEUI_uplink"]

    data["payload_hex"] =~ /^(..)(..)(....)(..)(..)(......)(......)(......)$/
    device = data["DevEUI"]
    lrresp = data['Lrrs']['Lrr'][0]['LrrESP']
    time = data["Time"].to_datetime.in_time_zone
    temperature = (convert_hex_to_signed_int($3) * 0.1).round(1)
    latitude = (convert_hex_to_signed_int($6) * 0.0001).round(4)
    longitude = (convert_hex_to_signed_int($7) * 0.0001).round(4)
    altitude = (convert_hex_to_signed_int($8) * 0.01).round(2)
    
    number = LoraDeviceMapping.find_by(device_registration: device)&.number

    Location.create(number: number, latitude: latitude, longitude: longitude,
                    time: time, device: device, lrresp: lrresp,
                    temperature: temperature, altitude: altitude)

    render json: ['Success'], status: 200
  end

  private
  def convert_hex_to_signed_int(data)
    bits = data.to_s.size * 4
    decimal = data.to_i(16)

    if decimal >= 2**(bits-1)
      decimal = 2**(bits) - decimal.to_s(2).to_i(2)
      decimal *= -1
    end

    decimal
  end

end
