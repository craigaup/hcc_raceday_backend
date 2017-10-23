class CheckpointController < ApplicationController
  def overview
    @refresh = 90
    @page_title = 'Checkpoint Overview'
    year = DateTime.now.in_time_zone.year
    @rawdata = Craft.getAllCheckpointHistory(nil, year)

    @count = @rawdata['___count']
    @averages = @rawdata['___averages']

  end

  def info
  end
end
