module CraftsHelper
  @forw = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'\
    .split(//)

  @rev = {}

  @forw.each_with_index do |x, index|
    @rev[x.to_s] = index
  end

  @arraysize = @forw.size

  @userlist = ['root', 'sydwest', 'start', 'alpha', 'bravo', 'charlie',
               'delta', 'echo', 'foxtrot', 'golf', 'hotel', 'india',
               'juliett', 'kilo', 'lima', 'pitstop', 'mike', 'november',
               'oscar', 'spencer', 'papa', 'quebec', 'sierra', 'tango',
               'finish', 'craigp', 'richard', 'doug', 'andrew', 'chris',
               'unknown']


  @statuslist = ['IN', 'OUT', 'DNS', 'WD']

  def self.convertvaltochars(myval)
    out = []
    return @forw[(myval % @arraysize)] if myval == 0 
    while (myval > 0)
      out.push(@forw[(myval % @arraysize)])
      myval = (myval / @arraysize).to_i
    end

    out.join('')
  end

  def self.convertcharstoval(chars)
    myval = 0
    value = 1

    chars.split(//).each do |ch|
      myval += value * @rev[ch.to_s]
      value *= @arraysize
    end

    myval
  end

  def self.convertstatustochars(status)
    statusmap = {}
    @statuslist.each_with_index do |x, index|
      statusmap[x] = CraftsHelper.convertvaltochars(index)
    end

    statusmap[status]
  end

  def self.convertcharstostatus(value)
    statusmap = {}
    @statuslist.each_with_index do |x, index|
      statusmap[x] = CraftsHelper.convertvaltochars(index)
    end

    revstatusmap = {}
    statusmap.each do |x, index|
      revstatusmap[index] = x
    end

    revstatu  def self.convertusernametochars(name)
    usermap = {}
    @userlist.each_with_index do |x, index|
      usermap[x] = CraftsHelper.convertvaltochars(index)
    end

    name = 'unknown' unless usermap.key?(name)
    usermap[name]
  end

  def self.convertcharstousername(value)
    usermap = {}
    @userlist.each_with_index do |x, index|
      usermap[x] = CraftsHelper.convertvaltochars(index)
    end

    revusermap = {}
    usermap.each do |x, index|
      revusermap[index] = x
    end

    revusermap[value]
  end
smap[value]
  end

  def self.convertusernametochars(name)
    usermap = {}
    @userlist.each_with_index do |x, index|
      usermap[x] = CraftsHelper.convertvaltochars(index)
    end

    name = 'unknown' unless usermap.key?(name)
    usermap[name]
  end

  def self.convertcharstousername(value)
    usermap = {}
    @userlist.each_with_index do |x, index|
      usermap[x] = CraftsHelper.convertvaltochars(index)
    end

    revusermap = {}
    usermap.each do |x, index|
      revusermap[index] = x
    end

    revusermap[value]
  end

  def self.generateHash(data, checksumtype = 'SHA256')
    raw_data = data.clone

    hash = ENV['HCC_INTERCONNECT_HASH']

    raw_data.delete('c')
    raw_data.delete('ct')

    OpenSSL::HMAC.hexdigest(checksumtype,
                            [hash].pack('H*'),
                            raw_data.to_json).split(//)[-8..-1].join()

  end

  def self.getData(checkpoint, interval, checksumtype = 'SHA256')
    checkpoints = []
    Distance.all.each do |checkpoint|
      checkpoints[checkpoint.id] = checkpoint.checkpoint
    end

    userlist = []
    User.all.each do |user|
      userlist[user.id] = user.username
    end

    initialcanoes = Craft.getData(checkpoint, interval)
    canoes = {}
    canoes = initialcanoes.map do |canoe|
      [
        CraftsHelper.convertvaltochars(canoe.number),
        CraftsHelper.convertstatustochars(canoe.status),
        CraftsHelper.convertvaltochars(canoe.time.to_i),
        checkpoints[canoe.checkpoint_id],
        CraftsHelper.convertusernametochars(userlist[canoe.user_id]),
        CraftsHelper.convertvaltochars(canoe.updated_at.to_i)
      ]
    end unless initialcanoes.nil?

    raw_data = {
      d: canoes,
      t:  CraftsHelper.convertvaltochars(Time.now.to_i),
    }

    raw_data[:c] = CraftsHelper.generateHash(raw_data, checksumtype)

    raw_data
  end
end
