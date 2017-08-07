class Api::V2017::StatusController < ApplicationController
  def types
    list = Datum.statusList
    render json: list, status: 200
  end
end
