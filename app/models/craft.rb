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
  
  def self.getStatus(canoeNumber, year = DateTime.now.year)
    dist = -1
    canoe = nil
    Craft.getHistory('124')[124].each do |key, tmparray|
      element = tmparray[-1]
      if element[:distance] > dist
        dist = element[:distance]
        canoe = element
      end
    end
    canoe
  end

  def self.getHistory(canoeNumber, year = DateTime.now.year)
    lastseen = {}
    Craft.where('year = ?', year).order(:entered).each do |canoe|
      next if canoeNumber != '' && canoe.number.to_s != canoeNumber.to_s
      number = canoe.number
      checkpointName = canoe.checkpoint.longname
      distance = (canoe.checkpoint.distance.to_f * 1000).round(0).to_i
 
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
    return nil if checkpointInfo.nil?

    mapCheckpoint = []
    Distance.all.each do |checkpoint|
      mapCheckpoint[checkpoint.id] = checkpoint
    end

    prevCheckpointInfo = nil
    distanceBetweenCP = 0

    if checkpointInfo.duesoonfrom != ''
      prevCheckpointInfo = Distance.findCheckpointEntry(
        checkpointInfo.duesoonfrom, year)
    end

    unless prevCheckpointInfo.nil?
      distanceBetweenCP = checkpointInfo.distance.to_f - prevCheckpoint.distance.to_f
    end

    defaultAverageSpeed = 15
    defaultTime = distanceBetweenCP / defaultAverageSpeed

    checkpointView = []
    canoesListIn = []
    Craft.where('year = ?', year).order(:entered).each do |canoe|
      number = canoe.number

      canoesListIn[canoe.checkpoint_id] = [] if \
        canoesListIn[canoe.checkpoint_id].nil?
      canoesListOut[canoe.checkpoint_id] = [] if \
        canoesListOut[canoe.checkpoint_id].nil?

      canoeListIn[canoe.checkpoint_id].push({canoe: number,
                                             time: canoe.time.to_i}) if \
                                            canoe.status == 'IN'

      canoeListOut[canoe.checkpoint_id][number] = canoe.time.to_i if \
        canoe.status == 'OUT'

      checkpointView[number] = {} if checkpointView[number].nil?
      if canoe.checkpoint_id == checkpointInfo.id && canoe.status == 'IN'
        checkpointView[number]['IN'] = {
          'status' => 'IN',
          'time' => getTimeFormat(canoe.time),
          'overdue' => 0
        }
        next
      end

      if canoe.checkpoint_id == checkpointInfo.id && canoe.status == 'OUT'
        checkpointView[number]['OUT'] = {
          'status' => 'OUT',
          'time' => canoe.time
        }
        if checkpointView[number]['IN'].nil?
          checkpointView[number]['IN'] = {
            'status' => 'IN',
            'time' => getTimeFormat(canoe.time),
            'overdue' => 0
          }
        end

        next
      end

      if !prevCheckpointInfo.nil? \
          && canoe.checkpoint_id == prevCheckpointInfo.id \
          && canoe.status == 'OUT'
        checkpointView[number]['IN'] = {
          'status' => 'Due Soon',
          'time' => getTimeFormat(canoe.time),
          'overdue' => 0
        }
        next
      end

      if canoe.status == 'DNS'
        checkpointView[number]['IN'] = {
          'status' => canoe.status,
          'time' => getTimeFormat(canoe.time),
          'overdue' => 0
        }
        next
      end

      myCheckpoint = mapCheckpoint[canoe.checkpoint_id].distance
      if canoe.status == 'WD' \
          && myCheckpoint.distance.to_f <= checkpointInfo.distance.to_f
        checkpointView[number]['IN'] = {
          'status' => canoe.status,
          'time' => canoe.status + ' ' + myCheckpoint.checkpoint,
          'overdue' => 0
        }

        next
      end

      if ( checkpointView[number]['IN'].nil? \
          || checkpointView[number]['IN']['status'] == 'Due Soon') 
        if myCheckpoint.distance.to_f >= checkpointInfo.distance.to_f 
          checkpointView[number]['IN'] = {'status' => 'LEFT',
                                          'overdue' => 0,
                                          'time' => myCheckpoint.checkpoint \
                                          + ' ' + getTimeFormat(canoe.time)}

          checkpointView[number]['OUT'] = {'status' => 'LEFT',
                                           'time' => myCheckpoint.checkpoint \
                                           + ' ' + getTimeFormat(canoe.time)}
          next
        end
      end


    end

    byebug

    checkpointView
  end

  private
  def isLate?(defaultAverageSpeed = 15)
  end

  def getTimeFormat(time, giveSeconds = False)
    array = time.localtime.to_a

    output = array[2].to_s + ':' + array[1].to_s
    output += ':' + array[0] if giveSeconds
    
    output
  end

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
