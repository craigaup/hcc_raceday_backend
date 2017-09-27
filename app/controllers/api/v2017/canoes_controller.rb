class Api::V2017::CanoesController < Api::V2017::ApplicationController
  before_action :authenticate_user,  only: [:add]
  def first
    number = Craft.findMinCanoeNumber
    render json: number, status: 200    
  end

  def last
    number = Craft.findMaxCanoeNumber
    render json: number, status: 200
  end

  def add
    canoeinfo = params.permit(:number, :status, :date_time, :checkpoint)
    newcraft = Craft.new
    newcraft.number = canoeinfo[:number]
    newcraft.status = canoeinfo[:status]
    newcraft.time = canoeinfo[:date_time]
    checkpointName = canoeinfo[:checkpoint]
    checkpointName = @current_user.username if checkpointName == '' \
      && @current_user.isCheckpoint?
    newcraft.year = DateTime.now.year
    checkpoint = Distance.findCheckpointEntry(checkpointName, newcraft.year)
    newcraft.checkpoint_id = checkpoint.id unless checkpoint.nil?
    newcraft.user_id = @current_user.id
    newcraft.entered = DateTime.now
      
    if !newcraft.save
      text = ['For canoe number ' + canoeinfo[:number].to_s]
      newcraft.errors.messages.each do |key, message|
        text.push(key.to_s + ' ' + message.join(' - '))
      end

      render json: text.join(' - '), status: 406
    else
      render json: 'Added canoe ' + newcraft.number.to_s + ' ' \
        + newcraft.status + ' at checkpoint ' + checkpointName, status: 200
    end
    
  end

  def history
    permittedParams = params.permit(:number)
    render json: Craft.getHistory(permittedParams[:number]), status: 200
  end

  def status
    permittedParams = params.permit(:number)
    render json: Craft.getStatus(permittedParams[:number]), status: 200
  end

  def sendData
    output = {}
    output['message'] = []
    output['status'] = 200

    canoeinfo = params.permit(:checksum, :time, :checksumtype).to_h

    canoeinfo['canoes'] = params['canoes'].to_ary
    canoeinfo['checksumtype'] = 'SHA256' unless canoeinfo.key?('checksumtype')


    if canoeinfo['checksum'].nil? || canoeinfo['time'].nil?
      render json: 'Something went wrong', status: 406
      return
    end

    checksum = canoeinfo[:checksum] 

    hash = ENV['HCC_INTERCONNECT_HASH']
    raw_data = JSON.parse(request.raw_post)
    raw_data.delete('checksum')
    raw_data.delete('checksumtype')

    currentChecksum = OpenSSL::HMAC.hexdigest(canoeinfo['checksumtype'],
                                              [hash].pack('H*'),
                                              raw_data.to_json)\
      .split(//)[-8..-1].join()


    if currentChecksum != checksum
      render json: 'Something went wrong - ', status: 406
      return
    end

    time = Time.strptime(canoeinfo['time'].to_s,"%S")

    canoeinfo['canoes'].each do |canoe|
      newcraft = Craft.new()

      newcraft.number = canoe[0]

      newcraft.status = canoe[1]

      newcraft.time = Time.strptime(canoe[2].to_s,"%S")

      newcraft.year = DateTime.now.year

      checkpointName = canoe[3]
      checkpoint = Distance.findCheckpointEntry(checkpointName, newcraft.year)
      newcraft.checkpoint_id = checkpoint.id unless checkpoint.nil?

      cuser = User.find_by(username: canoe[4].downcase)
      if cuser.nil?
        pass = BCrypt::Engine.generate_salt.split(//)[7..15].join()
        cuser = User.new(username: canoe[4].downcase, password: pass, 
                         confirm_password: pass)
        cuser.save
      end

      newcraft.user_id = cuser.id
      newcraft.entered = DateTime.now
      
      if !newcraft.save
        output['status'] = 406
        text = ['For canoe number ' + canoe[0]]
        newcraft.errors.messages.each do |key, message|
          text.push(key.to_s + ' ' + message.join(' - '))
        end

        output['message'].push(text.join(' - '))
      else
        output['message'].push("Added canoe #{newcraft.number} #{newcraft.status} at checkpoint #{checkpointName}")
      end
    end
    render json: output['message'].join("\n"), status: output['status']

  end
end
