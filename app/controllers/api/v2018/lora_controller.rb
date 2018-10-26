class Api::V2018::LoraController < Api::V2018::ApplicationController
  def sendData
    f = Tempfile.new('log', File.join(Rails.root, 'lora'))
    f.write(request.raw_post)
    f.close
    ObjectSpace.undefine_finalizer(f)
byebug
    render json: ['Success'], status: 200
  end
end
