class Api::V2017::CanoesController < Api::V2017::ApplicationController
  before_action :authenticate_user,  only: [:add, :info, :set_last]
  before_action :must_be_race_admin, only: [:info, :set_last]

  def first
    number = Craft.findMinCanoeNumber
    render json: number, status: 200    
  end

  def last
    number = Craft.findMaxCanoeNumber
    render json: number, status: 200
  end

  def set_last
    inf = params.permit(:number)
    if Datum.setValue('lastcanoenumber', inf[:number], DateTime.now.year)
      render json: {message: 'Success'}.to_json, status: 200
    else
      render json: {message: 'Error'}.to_json, status: 406
    end
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
    permittedParams = params.permit(:number, :interval)
    render json: Craft.getHistory(permittedParams[:number], \
                                  permittedParams[:interval], \
                                  DateTime.now.year
                                 ), status: 200
  end

  def status
    permittedParams = params.permit(:number, :interval)
    render json: Craft.getStatus(permittedParams[:number],
                                 permittedParams[:interval],
                                 DateTime.now.year
                                ), status: 200
  end

  def info
    permittedParams = params.permit(:number)

    base = ENV['HCC_REGISTRATION_BASEURL']
    url = base + '/api/v2017/teams/info'
    header = {'Content-Type': 'application/json'}
    uri = URI.parse(url)

    payload = {b: permittedParams[:number], t: DateTime.now.to_i}
    payload[:c] = CraftsHelper.generateHash(payload, "SHA256")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if base =~ /^https/
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = payload.to_json

    resp = http.request(request)
    if resp.code.to_s != 200.to_s
      render json: 'ERROR - ' + resp.message, status: resp.code
    else
      render json: resp.body, status: resp.code
    end

  end

  def field
    permittedParams = params.permit(:interval)
    render json: Craft.getFieldInfo(permittedParams[:interval],
                                    DateTime.now.year
                                   ), status: 200
  end

  def sendData
    output = {}
    output['message'] = []
    output['status'] = 200

    canoeinfo = params.permit(:c, :t, :ct).to_h
    canoeinfo['canoes'] = params['d'].to_ary

    canoeinfo['ct'] = 'SHA256' unless canoeinfo.key?('ct')

#byebug

    if canoeinfo['c'].nil? || canoeinfo['t'].nil?
      render json: 'Something went wrong', status: 406
      return
    end

    checksum = canoeinfo[:c] 

    raw_data = JSON.parse(request.raw_post)

    currentChecksum = CraftsHelper.generateHash(raw_data,
                                                canoeinfo['ct'])

    if currentChecksum != checksum
      render json: 'Something went wrong - ', status: 406
      return
    end

    time = Time.strptime(canoeinfo['t'].to_s,"%s")

    year = DateTime.now.year

    canoeinfo['canoes'].each do |canoe|
      number = canoe[0]

      status = canoe[1]

      time = Time.strptime(canoe[2].to_s,"%s")

      checkpointName = canoe[3]
      checkpoint = Distance.findCheckpointEntry(checkpointName, year)
      checkpoint_id = checkpoint.id unless checkpoint.nil?

      cuser = User.find_by(username: canoe[4].downcase)
      if cuser.nil?
        pass = BCrypt::Engine.generate_salt.split(//)[7..15].join()
        cuser = User.new(username: canoe[4].downcase, password: pass, 
                         confirm_password: pass)
        cuser.save
      end

      entered = if canoe[5].nil?
                  DateTime.now
                else
                  Time.strptime(canoe[5].to_s,"%s")
                end

      newcraft = Craft.find_by(
        {
          number: number,
          status: status,
          time: time,
          checkpoint_id: checkpoint_id
        }
      )

      next unless newcraft.nil?

      newcraft = Craft.new()

      newcraft.number = number
      newcraft.year = year
      newcraft.status = status
      newcraft.time = time
      newcraft.entered = entered
      newcraft.checkpoint_id = checkpoint_id

      newcraft.user_id = cuser.id
      
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
#byebug

    render json: output['message'].join("\n"), status: output['status']

  end

  def getData
    canoeinfo = params.permit(:checkpoint, :interval).to_h

    checksumtype = 'SHA256'

    CraftsHelper.getData(canoeinfo[:checkpoint], canoeinfo[:interval],\
                         checksumtype)
  end

  def finish_info
    render json: Craft.finish_info.to_json, status: 200
  end

  def withdrawal_list
    checkpoints = []

    Distance.all.each do |checkpoint|
      checkpoints[checkpoint.id] = checkpoint.checkpoint
    end

    output = Craft.where(status: 'WD').order(:created_at).map do |canoe|
      {
        number: canoe.number,
        status: 'WD ' + checkpoints[canoe.checkpoint_id],
        time: Craft.getTimeFormat(canoe.time)
      }
    end
    render json: output.to_json, status: 200
  end

  def nonstarter_list
    output = Craft.where(status: 'DNS').order(:created_at).map do |canoe|
      {
        number: canoe.number,
        status: 'DNS'
      }
    end
    render json: output.to_json, status: 200
  end

  def locations
    precision = 4

    canoe = 'all'
    canoe = params['canoes'].split(',') if !params['canoes'].nil? \
      && params['canoes'] =~ /^(\d+,)+/

    uniq = true
    uniq = false if !params['uniq'].nil? \
      && params['uniq'].to_s.casecmp('false').zero?

    show_checkpoints = true
    show_checkpoints = false if !params['show_checkpoints'].nil? \
      && params['show_checkpoints'].to_s.casecmp('false').zero?

    output = if uniq
              Location.uniq_location(precision, canoe, show_checkpoints)
            else
              Location.show(precision, canoe, show_checkpoints)
            end

    render json: output.to_json, status: 200
  end
end
