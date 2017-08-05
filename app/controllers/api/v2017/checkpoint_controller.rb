class Api::V2017::CheckpointController < Api::V2017::ApplicationController
  before_action :authenticate_user

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
      newcraft.checkpoint_id = checkpoint[0].id unless checkpoint.nil?
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

  def history
  end

  def sendMessage
  end
end
