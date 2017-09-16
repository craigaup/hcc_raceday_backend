class Api::V2017::CheckpointsController < Api::V2017::ApplicationController
  before_action :authenticate_user, except: [:info, :status]

  def info
    checkpoints = Distance.getAllCheckpointInformation
    render json: checkpoints, status: 200
  end


  def sendCanoe
    output = {}
    output['message'] = []
    output['status'] = 200

    canoeinfo = params.permit(:canoes => [:number, :status, :time, :checkpoint])
    canoeinfo['canoes'].each do |canoe|
      newcraft = Craft.new()
      newcraft.number = canoe['number']
      newcraft.status = canoe['status']
      newcraft.time = canoe['time']
      checkpointName = canoe['checkpoint']
      checkpointName = @current_user.username if checkpointName == '' \
        && @current_user.isCheckpoint?
      newcraft.year = DateTime.now.year
      checkpoint = Distance.findCheckpointEntry(checkpointName, newcraft.year)
      newcraft.checkpoint_id = checkpoint.id unless checkpoint.nil?
      newcraft.user_id = @current_user.id
      newcraft.entered = DateTime.now
      
      if !newcraft.save
        output['status'] = 406
        text = ['For canoe number ' + canoe['number']]
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

  def status
    permParams = params.permit(:checkpoint, :interval)

    checkpointInfo = Distance.findCheckpointEntry(permParams[:checkpoint])
    if checkpointInfo.nil?
      render json: 'Problem with Checkpoint Name', status: 406
    end

    interval = nil
    unless permParams[:interval].nil?
      interval = permParams[:interval].to_i if permParams[:interval].to_i > 0
    end

    render json: Craft.displayCheckpointInfo(checkpointInfo.longname,
                                             interval),\
      status: 200
  end

  def historyAll
  end
end
