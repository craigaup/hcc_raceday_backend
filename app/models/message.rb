class Message < ApplicationRecord
  belongs_to :user

  def self.get_messages(canoe_number, interval = nil,
                        year = DateTime.zone.now.year)
    return {} unless canoe_number.to_s.casecmp('all').zero? \
      || canoeNumber.to_s =~ /^\d+$/

    since = 0
    if interval.to_s =~ /^\d+$/
      since = interval.minutes.ago.to_i
    elsif !interval.nil?
      return {}
    end

    mlist = []
    Message.where(year: year).order('time').each do |m|
      next if since != 0 && m.time.nil?
      next if !m.time.nil? && m.time.to_i < since
      next if !m.validtil.nil? && m.validtil < DateTime.zone.now

      hash = { messagenumber: m.id, to: m.to, from: m.from,
               time: m.message_time, priority: m.priority, ack: m.displayed,
               til: m.validtil, entered: m.entered }

      hash[:by] = if m.user.nil? 
                    nil
                  else
                    m.user.username
                  end

      mlist.push(hash)
    end

    mlist
  end
end
