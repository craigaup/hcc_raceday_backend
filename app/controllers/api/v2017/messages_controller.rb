class Api::V2017::CanoesController < Api::V2017::ApplicationController
  before_action :authenticate_user,  only: [:send]
  # before_action :must_be_race_admin, only: [:info, :set_last]

  def send
    inf = params.permit(:to, :from, :time, :priority, :message, :til)
    message = Message.new
    message.user = current_user
    message.entered = DateTime.zone.now
    message.year = DateTime.zone.now.year

    message.to = inf[:to]
    message.from = inf[:from]
    message.message_time = inf[:time]
    message.priority = inf[:priority]
    message.message = inf[:message]
    message.til = inf[:til]

    unless message.save
      render json: {message: @message.errors}.to_json, \
        status: :unprocessable_entity
    end

    render json: {message: 'Success'}.to_json, status: 200
  end

  def get
    inf = params.permit(:number, :interval)
    render json: Message.get_messages(inf[:number], inf[:interval], 
                                      DateTime.zone.now.year).to_json), \
      status: 200
  end


  def acknowledge
    inf = params.permit(:number, :canoe)

    m = Message.find_by(id: inf[:number])
    if m.nil?
      return json: {message: 'Not found'}.to_json, status: 406
    elsif m.to != inf[:canoe]
      return json: {message: 'Input Error'}.to_json, status: 406
    end

    m.displayed = DateTime.zone.now
    unless m.save
      return json: {message: 'Error'}.to_json, status: 406
    end

    return json: {message: 'Success'}.to_json, status: 200
  end
end