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
    inf = params.permit(:checkpoint)

    @refresh = 90
    checkpointInfo = Distance.findCheckpointEntry(inf[:checkpoint])
    if checkpointInfo.nil?
      redirect_to checkpoint_overview_path
    end

    @page_title = 'Checkpoint ' + checkpointInfo.longname
    display = Craft.displayCheckpointInfo(checkpointInfo.longname)
    
    @checkpoint = checkpointInfo.longname

    @display = []
    count = 0
    modulus = ((display.size / 7.0) + 0.5).round
    display.each do |canoe|
      y = (count / modulus).to_i
      x = (count % modulus)

      @display[x] = [] if @display[x].nil?
      @display[x][y] = canoe

      count += 1
    end
  end
end
