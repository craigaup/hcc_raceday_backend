class Distance < ApplicationRecord
  def self.getAllCheckpointInformation(year=DateTime.now.year)
    year = year.to_s
    checkpoints = []
    Distance.where('year = ?', year).each do |tmpdist|
      checkpoints.push({id: tmpdist.id,
                        shortname: tmpdist.checkpoint,
                        longname: tmpdist.longname,
                        distance: tmpdist.distance,
                        duesoonfrom: tmpdist.duesoonfrom})
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

end
