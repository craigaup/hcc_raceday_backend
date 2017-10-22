class CheckpointController < ApplicationController
  def overview
    @refresh = 90
    @page_title = 'Checkpoint Overview'
  end

  def info
  end
end
