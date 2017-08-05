class Api::V2017::DataController < ApplicationController
  def getCheckpointInfo
    checkpoints = Distance.getAllCheckpointInformation
    render json: checkpoints, status: 200
  end

  def getFirstCanoeNumber
    number = Craft.findMinCanoeNumber
    render json: number, status: 200
  end

  def getLastCanoeNumber
    number = Craft.findMaxCanoeNumber
    render json: number, status: 200
  end

  def getCanoeStatusInfo
    list = Datum.statusList
    render json: list, status: 200
  end
end
