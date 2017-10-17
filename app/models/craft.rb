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
    minCanoeNumber = Datum.returnValue('firstcanoenumber',year)

    if minCanoeNumber.nil?
      return 100
    end

    minCanoeNumber.to_i
  end
  
  def self.findMaxCanoeNumber(year = DateTime.now.year)
    maxCanoeNumber = Datum.returnValue('lastcanoenumber',year)

    if maxCanoeNumber.nil?
      return 500
    end

    maxCanoeNumber.to_i
  end
  
  def self.getStatus(canoeNumber, year = DateTime.now.year)
    dist = -1
    canoe = nil
    canoeNumber = canoeNumber.to_i
    history = Craft.getHistory(canoeNumber)
    return {} if history.empty?
    history[canoeNumber].each do |key, tmparray|
      element = tmparray[-1]
      if element[:distance] > dist
        dist = element[:distance]
        canoe = element
      end
    end
    canoe
  end

  # def self.getHistory(canoeNumber, year = DateTime.now.year)
  #   lastseen = {}
  #   Craft.where('year = ?', year).order(:entered).each do |canoe|
  #     next if canoeNumber != '' && canoe.number.to_s != canoeNumber.to_s
  #     number = canoe.number
  #     checkpointName = canoe.checkpoint.longname
  #     distance = (canoe.checkpoint.distance.to_f * 1000).round(0).to_i
 
  #     if !lastseen.key?(number)
  #       lastseen[number] = {}
  #     end

  #     if !lastseen[number].key?(checkpointName)
  #       lastseen[number][checkpointName] = []
  #     end
  #     lastseen[number][checkpointName].push({ number: number,
  #                                             checkpoint: checkpointName,
  #                                             status: canoe.status,
  #                                             time: canoe.time,
  #                                             distance: distance })
  #   end
  #   lastseen
  # end

  def self.getHistory(canoeNumber, interval = 'ALL', year = DateTime.now.year)
    lastseen = {}
    list = if canoeNumber.nil? || canoeNumber == '' \
        || canoeNumber.upcase == 'ALL'
             Craft.where('year = ?', year).order(:entered)
           else
             Craft.where('year = ? AND number = ?', year, canoeNumber).order(:entered)
           end

    interval = 'ALL' if interval.nil?
    return lastseen unless interval =~ /^\d+$/ || interval.upcase == 'ALL'

    if interval.upcase == 'ALL'
      oldtime = 0
    else
      oldtime = interval.to_i.minutes.ago.to_i
    end

    mapCheckpoint = []
    Distance.all.each do |checkpoint|
      mapCheckpoint[checkpoint.id] = checkpoint
    end

    list.each do |canoe|
      number = canoe.number
      next unless canoe.updated_at.to_i >= oldtime

      checkpointName = mapCheckpoint[canoe.checkpoint_id].longname
      distance = (mapCheckpoint[canoe.checkpoint_id].distance.to_f * 1000).round(0).to_i
 
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
                                              distance: distance })
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

  def self.getAllCheckpointInfo(mapCheckpoint = nil, year = DateTime.now.year)
    data = {}
    unless mapCheckpoint.is_a? Array
      mapCheckpoint = []
      Distance.all.each do |checkpoint|
        mapCheckpoint[checkpoint.id] = checkpoint
      end
    end

    Craft.where('year = ?', year).order(:entered).each do |canoe|
      number = canoe.number
      checkpointName = mapCheckpoint[canoe.checkpoint_id].longname

      data[checkpointName] = [] unless data.key?(checkpointName)
      data[checkpointName][number] = {} if data[checkpointName][number].nil?
      data[checkpointName][number]['IN'] = canoe if canoe.status == 'IN'
      if canoe.status == 'OUT'
        data[checkpointName][number]['OUT'] = canoe
        data[checkpointName][number]['IN'] = canoe if \
          data[checkpointName][number]['IN'].nil?
      end

      if canoe.status == 'WD' || canoe.status == 'DNS'
        myDistance = mapCheckpoint[canoe.checkpoint_id].distance.to_f
        mapCheckpoint.each do |checkpoint|
          next if checkpoint.nil?
          if checkpoint.id == canoe.checkpoint_id
            data[checkpointName][number]['IN'] = canoe
            next
          end

          if checkpoint.distance.to_f > myDistance
            data[checkpoint.longname] = [] unless data.key?(checkpoint.longname)
            data[checkpoint.longname][number] = {} if data[checkpoint.longname][number].nil?
            data[checkpoint.longname][number]['IN'] = canoe
            next
          end
        end
      end
    end

    data
  end

  def overdue?
    return false
  end

  def self.getData(checkpointName, interval, year = DateTime.now.year)
    return nil if interval.nil?
    return nil if checkpointName.nil?
    return nil unless interval =~ /^\d+$/ || interval == 'ALL'

    if interval == 'ALL'
      oldtime = 0
    else
      oldtime = interval.minutes.ago.to_i
    end

    if checkpointName != 'ALL'
      myCheckpoint = nil
      myDistance = nil
      myCheckpointID = nil
      myCheckpointDueSoonFrom = nil
      mapCheckpoint = []
      Distance.all.each do |checkpoint|
        mapCheckpoint[checkpoint.id] = checkpoint
        if checkpoint.checkpoint == checkpointName \
            || checkpoint.longname == checkpointName
          myCheckpoint = checkpoint.longname
          myDistance = checkpoint.distance.to_f
          myCheckpointID = checkpoint.id
          myCheckpointDueSoonFrom = checkpoint.duesoonfrom unless \
            checkpoint.duesoonfrom == ''
        end
      end

      return nil if myCheckpoint.nil?

      list = Craft.where({year: year, checkpoint_id: myCheckpointID})
    else
      list = Craft.where({year: year})
    end

    list.select do |canoe|
      canoe if canoe.updated_at.to_i >= oldtime
    end
  end

  def self.displayCheckpointInfo(checkpointName, interval = nil,
                                 year = DateTime.now.year)
    unless interval.nil?
      oldtime = interval.minutes.ago.to_i
    end

    myCheckpoint = nil
    myDistance = nil
    myCheckpointID = nil
    myCheckpointDueSoonFrom = nil
    mapCheckpoint = []
    Distance.all.each do |checkpoint|
      mapCheckpoint[checkpoint.id] = checkpoint
      if checkpoint.checkpoint == checkpointName \
          || checkpoint.longname == checkpointName
        myCheckpoint = checkpoint.longname
        myDistance = checkpoint.distance.to_f
        myCheckpointID = checkpoint.id
        myCheckpointDueSoonFrom = checkpoint.duesoonfrom unless \
          checkpoint.duesoonfrom == ''
      end
    end

    return nil if myCheckpoint.nil?

    rawdata = getAllCheckpointInfo(mapCheckpoint, year)

    firstCanoe = findMinCanoeNumber
    lastCanoe = findMaxCanoeNumber
    notSeen = []
    data = []

    (firstCanoe .. lastCanoe).each do |canoeNumber|
      if (rawdata[myCheckpoint].nil? \
          || rawdata[myCheckpoint][canoeNumber].nil? \
          || (rawdata[myCheckpoint][canoeNumber]['IN'].nil? \
              && rawdata[myCheckpoint][canoeNumber]['OUT'].nil?))
        notSeen.push(canoeNumber)
        next
      end

      if rawdata[myCheckpoint][canoeNumber]['IN'].nil? \
          && !rawdata[myCheckpoint][canoeNumber]['OUT'].nil?
        rawdata[myCheckpoint][canoeNumber]['IN'] = \
          rawdata[myCheckpoint][canoeNumber]['OUT']
      end
    end


    data = rawdata[myCheckpoint].clone if !rawdata.nil? && !rawdata[myCheckpoint].nil?

    notSeen.each do |canoeNumber|
      mapCheckpoint.each do |checkpoint|
        next if checkpoint.nil?
        next unless data[canoeNumber].nil?

        next unless checkpoint.distance.to_f > myDistance
        if !rawdata[checkpoint.longname].nil? \
            && !rawdata[checkpoint.longname][canoeNumber].nil?
          if !rawdata[checkpoint.longname][canoeNumber]['IN'].nil?
            data[canoeNumber] = {}
            data[canoeNumber]['IN'] = rawdata[checkpoint.longname][canoeNumber]['IN']
            data[canoeNumber]['OUT'] = nil
          elsif !rawdata[checkpoint.longname][canoeNumber]['OUT'].nil?
            data[canoeNumber] = {}
            data[canoeNumber]['IN'] = rawdata[checkpoint.longname][canoeNumber]['OUT']
            data[canoeNumber]['OUT'] = nil
          end
        end
      end
    end

    unless myCheckpointDueSoonFrom.nil?
      found = false
      mapCheckpoint.each do |checkpoint|
        next if found
        next if checkpoint.nil?
        if checkpoint.checkpoint == myCheckpointDueSoonFrom \
          || checkpoint.longname == myCheckpointDueSoonFrom
          found = true
          myCheckpointDueSoonFrom = checkpoint.longname
        end
      end

      notSeen.each do |canoeNumber|
        next unless data[canoeNumber].nil?
        next if rawdata[myCheckpointDueSoonFrom].nil?
        next if rawdata[myCheckpointDueSoonFrom][canoeNumber].nil?
        data[canoeNumber] = {}
        data[canoeNumber]['IN'] = rawdata[myCheckpointDueSoonFrom][canoeNumber]['OUT']
        data[canoeNumber]['OUT'] = nil
      end

    end

    returnData = {}
    (firstCanoe .. lastCanoe).each do |canoeNumber|
      next if data[canoeNumber].nil? || data[canoeNumber]['IN'].nil?

      unless interval.nil?
        intime =  data[canoeNumber]['IN'].updated_at.to_i

        intime = Time.now.to_i if data[canoeNumber]['IN'].overdue?

        if data[canoeNumber]['OUT'].nil?
          next unless oldtime <= intime
        else
          outtime = data[canoeNumber]['OUT'].updated_at.to_i
          next unless ((oldtime <= intime) || ( oldtime <= outtime ))
        end
      end

      returnData[canoeNumber] = {}

      tmpdata = data[canoeNumber]['IN']

      if tmpdata.status == 'DNS'
        returnData[canoeNumber]['IN'] = { 'status' => 'DNS',
                                          'time' => 'DNS',
                                          'overdue' => false
        }
      elsif tmpdata.status == 'WD'
        returnData[canoeNumber]['IN'] = { 'status' => 'WD',
                                          'time' => 'WD ' + mapCheckpoint[tmpdata.checkpoint_id].checkpoint,
                                          'overdue' => false
        }
      elsif tmpdata.checkpoint_id == myCheckpointID
        returnData[canoeNumber]['IN'] = { 'status' => 'IN',
                                          'time' => \
                                          getTimeFormat(tmpdata.time, true),
                                          'overdue' => false
        }

        unless data[canoeNumber]['OUT'].nil?
          tmpdata = data[canoeNumber]['OUT']
          returnData[canoeNumber]['OUT'] = { 'status' => 'OUT',
                                             'time' => \
                                             getTimeFormat(tmpdata.time, true),
                                             'overdue' => false
          }
        end
      elsif mapCheckpoint[tmpdata.checkpoint_id].distance.to_f < myDistance
        returnData[canoeNumber]['IN'] = { 'status' => 'DUESOON',
                                          'time' => \
                                          getTimeFormat(tmpdata.time),
                                          'overdue' => false
        }
      elsif mapCheckpoint[tmpdata.checkpoint_id].distance.to_f > myDistance
        returnData[canoeNumber]['IN'] = { 'status' => 'SKIPPED', 
                                          'time' => mapCheckpoint[tmpdata.checkpoint_id].checkpoint + ' at ' + \
                                          getTimeFormat(tmpdata.time),
                                          'overdue' => false
        }
      end
    end

    returnData
  end

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

    checkpointView
  end

  private
  def isLate?(defaultAverageSpeed = 15)
  end

  def self.getTimeFormat(time, giveSeconds = false)
    array = time.to_a

    if giveSeconds
      output = sprintf('%d:%2d:%2d', array[2], array[1], array[0])\
        .gsub(/ /, '0')
    else
      output = sprintf('%d:%2d', array[2], array[1]).gsub(/ /, '0')
    end
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
