class Api::V2018::LoraController < Api::V2018::ApplicationController
  def sendData
    f = Tempfile.new('log', '/tmp/lora')
    f.write(request.raw_post)
    f.close
    render json: ['Success'], status: 200
  end
end
