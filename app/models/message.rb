class Message < ApplicationRecord
  belongs_to :user

  def self.get_messages(canoe_number, interval = nil,
                        year = DateTime.now.in_time_zone.year)
    return {} unless canoe_number.to_s.casecmp('all').zero? \
      || canoe_number.to_s =~ /^\d+$/

    since = 0
    if interval.to_s =~ /^\d+$/
      since = interval.minutes.ago.to_i
    elsif !interval.nil?
      return {}
    end

    mlist = []
    nowtime = DateTime.now.in_time_zone
    Message.where(year: year).order('message_time').each do |m|
      next if since != 0 && m.message_time.nil?
      next if !m.message_time.nil? && m.message_time.to_i < since
      next if !m.validtil.nil? && m.validtil < nowtime

      next unless canoe_number.to_s.casecmp('all').zero? \
        || m.number.to_s == canoe_number.to_s

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
