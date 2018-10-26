class Api::V2018::LoraController < Api::V2018::ApplicationController
  def sendData
    f = Tempfile.new('log', File.join(Rails.root, 'lora'))
    f.write(request.raw_post)
    f.close
    ObjectSpace.undefine_finalizer(f)

    data = JSON.parse(request.raw_post)["DevEUI_uplink"]

    device = data["DevEUI"]
    lrresp = data['Lrrs']['Lrr'][0]['LrrESP']
    time = data["Time"].to_datetime.in_time_zone
    temperature = ''
    latitude = ''
    longitude = ''
    altitude = ''

    # data["payload_hex"] =~ /^(..)(..)(....)(..)(..)(......)(......)(......)$/

    while (!data['payload_hex'].empty?) do
      if data['payload_hex'] =~ /^0d67(....)(.*)$/
        temperature = (convert_hex_to_signed_int($1) * 0.1).round(1)
        data['payload_hex'] = $2
      elsif data['payload_hex'] =~ /^1488(......)(......)(......)(.*)$/
        latitude = (convert_hex_to_signed_int($1) * 0.0001).round(4)
        longitude = (convert_hex_to_signed_int($2) * 0.0001).round(4)
        altitude = (convert_hex_to_signed_int($3) * 0.01).round(2)
        data['payload_hex'] = $4
      else
        data['payload_hex'] = ''
      end
    end

    if latitude.to_s.empty? || longitude.to_s.empty?
      render json: ['Success'], status: 200
      return
    end

    temperature = nil if temperature.empty?

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
