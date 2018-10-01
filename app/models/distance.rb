class Distance < ApplicationRecord
  def self.getAllCheckpointInformation(year=DateTime.now.year)
    year = year.to_s
    checkpoints = []
    Distance.where('year = ?', year).each do |tmpdist|
      checkpoints.push({id: tmpdist.id,
                        shortname: tmpdist.checkpoint,
                        longname: tmpdist.longname,
                        distance: tmpdist.distance,
                        duesoonfrom: tmpdist.duesoonfrom,
                        latitude: tmpdist.latitude,
                        longitude: tmpdist.longitude})
    end
    checkpoints
  end

  def self.findCheckpointEntry(name, year=DateTime.now.year)
    Distance.where('year = ?', year).each do |element|
      return element if element.checkpoint.downcase == name.downcase
      return element if element.longname.downcase == name.downcase
    end
    nil
  end

  def self.getCheckpointMapping(mapCheckpoint = nil,
                                year = DateTime.now.in_time_zone.year)
    if mapCheckpoint.is_a? Array
      tmpCheckpoint = mapCheckpoint
      mapCheckpoint = {}
      tmpCheckpoint.each_with_index do |checkpoint, id|
        next if checkpoint.nil?
        mapCheckpoint[id] = checkpoint
      end
    elsif !mapCheckpoint.is_a? Hash
      mapCheckpoint = {}
      Distance.where(year: year).each do |checkpoint|
        next if checkpoint.nil?
        mapCheckpoint[checkpoint.id] = checkpoint
      end
    end

    mapCheckpoint
  end
end
