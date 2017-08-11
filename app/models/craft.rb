class Craft < ApplicationRecord
  belongs_to :user, optional: false
  belongs_to :checkpoint, class_name: 'Distance', optional: false

  before_validation :setStatus
  validate :checkCanoeNumberValue
  validate :checkStatusIsValid
  validates :number, presence: true, numericality: true
  validates :year, presence: true, numericality: true
  validates :entered, presence: true
  validates :time, presence: true

  def self.findMinCanoeNumber(year = DateTime.now.year)
    minCanoeNumber = Datum.where('lower(key) = lower(?) and year = ?',
                                'firstcanoenumber',year.to_s)
    if minCanoeNumber.nil? || minCanoeNumber.last.nil?
      return 100
    end

    minCanoeNumber.last.data.to_i
  end
  
  def self.findMaxCanoeNumber(year = DateTime.now.year)
    maxCanoeNumber = Datum.where('lower(key) = lower(?) and year = ?',
                                'lastcanoenumber',year.to_s)
    if maxCanoeNumber.nil? || maxCanoeNumber.last.nil?
      return 500
    end
    maxCanoeNumber.last.data.to_i
  end
  
  def self.getHistory(canoeNumber, year = DateTime.now.year)
    lastseen = {}
    Craft.where('year = ?', year).order(:entered).each do |canoe|
      next if canoeNumber != '' && canoe.number.to_s != canoeNumber.to_s
      number = canoe.number
      checkpointName = canoe.checkpoint.longname
      distance = (canoe.checkpoint.distance * 1000).round(0).to_i
 
      if !lastseen.key?(number)
        lastseen[number] = {}
      end

      if !lastseen[number].key?(checkpointName)
        lastseen[number][checkpointName] = []
      end
      lastseen[number][checkpointName].push({ number: number,
                                              checkpoint: checkpointName,
                                              status: canoe.status,
                                              time: canoe.time,
                                              distance: distance})
    end
    lastseen
  end

#   def self.getCheckpointHistory(checkpointName, year = DateTime.now.year)
#     #checkpointinfo = Distance.findCheckpointEntry(checkpointName, year)
# 
#     #lastseen = { duesoonlist: {}, checkpointlist: {}, overduelist: {} }
#     #return lastseen if checkpointinfo.nil?
# 
#     #duesooncheckpoint = checkpointinfo.duesoonfrom
#     #distance = checkpointinfo.distance
#     seen = {}
#     checkpoints = {}
#     lastseen = {}
# 
#     Craft.where('year = ?', year).order(:entered).each do |canoe|
#       number = canoe.number
#       checkpointName = canoe.checkpoint.longname
#       distance = (canoe.checkpoint.distance.to_f * 1000).round(0).to_i
#       if !seen.key?(checkpointName)
#         seen[checkpointName] = {}
#         checkpoints[checkpointName] = distance
#       end
# 
#       lastseen[number] = checkpointName
#       seen[checkpointName][number] = { number: number,
#                                        checkpoint: checkpointName,
#                                        status: canoe.status,
#                                        time: canoe.time,
#                                        distance: distance}
# 
#       checkpoints.each do |tmpname, tmpdistance|
#         next if seen[tmpname].key?(number)
#         next if checkpointName == tmpname
#         next if distance < tmpdistance
# 
#         seen[tmpname][number] = { number: number,
#                                   checkpoint: tmpname,
#                                   status: 'OUT',
#                                   time: nil,
#                                   distance: tmpdistance}
#       end
#     end
#     seen
#   end

  def self.getAllCheckpointHistory(checkpointName, year = DateTime.now.year)
    #checkpointinfo = Distance.findCheckpointEntry(checkpointName, year)

    #lastseen = { duesoonlist: {}, checkpointlist: {}, overduelist: {} }
    #return lastseen if checkpointinfo.nil?

    #duesooncheckpoint = checkpointinfo.duesoonfrom
    #distance = checkpointinfo.distance
    seen = {}
    checkpoints = {}
    lastseen = {}

    Craft.where('year = ?', year).order(:entered).each do |canoe|
      number = canoe.number
      checkpointName = canoe.checkpoint.longname
      distance = (canoe.checkpoint.distance.to_f * 1000).round(0).to_i
      if !seen.key?(checkpointName)
        seen[checkpointName] = {}
        checkpoints[checkpointName] = distance
      end

      lastseen[number] = checkpointName
      seen[checkpointName][number] = { number: number,
                                       checkpoint: checkpointName,
                                       status: canoe.status,
                                       time: canoe.time,
                                       distance: distance}

      checkpoints.each do |tmpname, tmpdistance|
        next if seen[tmpname].key?(number)
        next if checkpointName == tmpname
        next if distance < tmpdistance

        seen[tmpname][number] = { number: number,
                                  checkpoint: tmpname,
                                  status: 'OUT',
                                  time: nil,
                                  distance: tmpdistance}
      end
    end
    seen
  end

  def self.getCheckpointInformation(checkpointName, year = DateTime.now.year)
    checkpointInfo = Distance.findCheckpointEntry(checkpointName, year)
    prevCheckpointInfo = nil
    if checkpointInfo.duesoonfrom != ''
      prevCheckpointInfo = Distance.findCheckpointEntry(
        checkpointInfo.duesoonfrom, year)
    end

    canoes = []
    Craft.where('year = ?', year).order(:entered).each do |canoe|
      number = canoe.number
      if canoe.checkpoint_id == checkpointInfo.id && canoe.status == 'IN'
        canoes[number] = {
          'status' => 'IN',
          'time' => canoe.time
        }
        next
      end

      if !prevCheckpointInfo.nil? && canoe.checkpoint_id == prevCheckpointInfo.id && canoe.status == 'OUT'
        canoes[number] = {
          'status' => 'Due Soon',
          'time' => canoe.time
        }
        next
      end

      if canoe.status == 'DNS'
        canoes[number] = {
          'status' => canoe.status,
          'time' => canoe.time
        }
        next
      end

      if canoe.status == 'WD' && canoe.checkpoint.distance.to_f <= checkpointInfo.distance.to_f
        canoes[number] = {
          'status' => canoe.status + ' ' + canoe.checkpoint.checkpoint,
          'time' => canoe.time
        }

        next
      end

      if ( canoes[number].nil? || canoes[number]['status'] == 'Due Soon') 
        if canoe.checkpoint.distance.to_f >= checkpointInfo.distance.to_f 
          canoes[number] = {'status' => 'PAST', 'time' => '-'}
          next
        end
      end


    end

    checkpointView = []

    canoes.each_with_index do |canoe, number|
      next if canoe.nil?
      canoe['overdue'] = 0

      checkpointView[number] = canoe
    end

    checkpointView
  end

  private
  def checkCanoeNumberValue(year = DateTime.now.year)
    minCanoeNumber = Craft.findMinCanoeNumber
    maxCanoeNumber = Craft.findMaxCanoeNumber
    if number < minCanoeNumber|| number > maxCanoeNumber
      errors.add(:number, :invalid_value,
                 message: 'is outside of range for canoe numbers (' + \
                 minCanoeNumber.to_s + ' to ' + maxCanoeNumber.to_s + ')')
    end
  end

  def setStatus
    statusList = Datum.statusList

    return if status.nil? || status == ''

    statusList.each do |element|
      self.status = element[:shortname] if element.key?(:shortname) \
        && element[:shortname].downcase == status.downcase
      self.status = element[:shortname] if element.key?(:shortname) \
        && element.key?(:longname) \
        && element[:longname].downcase == status.downcase
      return if element.key?(:shortname) && element[:shortname] == status
    end
  end


  def checkStatusIsValid
    statusList = Datum.statusList
    statusList.each do |element|
      return if element.key?(:shortname) && element[:shortname] == status
    end

    errors.add(:status, :invalid_value,
               message: 'is not a valid entry')
  end
end
