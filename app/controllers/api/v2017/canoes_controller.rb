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
end
