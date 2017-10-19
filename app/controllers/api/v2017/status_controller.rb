class Api::V2017::StatusController < Api::V2017::ApplicationController
  before_action :authenticate_user,  only: [:set_complete]
  before_action :must_be_race_admin, only: [:set_complete]

  def types
    list = Datum.statusList
    render json: list, status: 200
  end

  def getComplete
    value = Datum.returnValue('nonstarterscomplete', DateTime.now.year)
    value = false.to_s if value.nil?
    render json: {message: value}.to_json, status: 200
  end

  def setComplete
    if Datum.setValue('nonstarterscomplete', DateTime.now, DateTime.now.year)
      render json: {message: 'Successful'}.to_json, status: 200
    else
      render json: {message: 'ERROR'}.to_json, status: 406
    end

  end
end
