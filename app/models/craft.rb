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

      if !lastseen.key?(number)
        lastseen[number] = {}
      end

      if !lastseen[number].key?(checkpointName)
        lastseen[number][checkpointName] = []
      end
      lastseen[number][checkpointName].push({ number: number,
                                              checkpoint: checkpointName,
                                              status: canoe.status,
                                              time: canoe.time})
    end
    lastseen
  end

  def self.getCheckpointHistory(checkpointName, year = DateTime.now.year)
    checkpointinfo = Distance.findCheckpointEntry(checkpointName, year)

    lastseen = { duesoonlist: {}, checkpointlist: {}, overduelist: {} }
    return lastseen if checkpointinfo.nil?

    duesooncheckpoint = checkpointinfo.duesoonfrom
    distance = checkpointinfo.distance
    Craft.where('year = ? and checkpoint_id = ?', year, checkpointinfo.id).each do |canoe|
      number = canoe.number
      if lastseen[:checkpointlist].key?(number)
        # Need to make sure if entered time is greater than last entry
        # and if so next
      end
      lastseen[:checkpointlist][number] = { number: canoe.number,
                                             status: canoe.status,
                                             time: canoe.time,
                                             entered: canoe.entered,
                                             checkpoint: canoe.checkpoint.longname }
    end

#    if duesooncheckpoint
    lastseen

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
