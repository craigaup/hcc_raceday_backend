class CheckpointController < ApplicationController
  def overview
    @refresh = 90
    @page_title = 'Checkpoint Overview'
    year = DateTime.now.in_time_zone.year
    @rawdata = Craft.getAllCheckpointHistory(nil, year)

    @count = @rawdata['___count']
    @averages = @rawdata['___averages']
    @url = checkpoint_overview_url
  end

  def info
    inf = params.permit(:checkpoint)

    @refresh = 90
    checkpointInfo = Distance.findCheckpointEntry(inf[:checkpoint])
    if checkpointInfo.nil?
      redirect_to checkpoint_overview_path
    end
    @url = checkpoint_info_url(inf[:checkpoint]) 

    @page_title = 'Checkpoint ' + checkpointInfo.longname
    display = Craft.displayCheckpointInfo(checkpointInfo.longname)
    
    @min = 1000
    @max = 0
    display.keys.each do |num|
      @min = num if num < @min
      @max = num if num > @max
    end

    @checkpoint = checkpointInfo.longname

    @display = []
    count = 0
    (@min..@max).each do |canoe|
      display[canoe] = {} unless display.key?(canoe)
    end

    @columns = 13.0
    modulus = ((display.size / @columns) + 0.5).round
    display.sort.each do |canoe|
      y = (count / modulus).to_i
      x = (count % modulus)

      @display[x] = [] if @display[x].nil?
      @display[x][y] = canoe

      count += 1
    end

    #byebug
  end
end
