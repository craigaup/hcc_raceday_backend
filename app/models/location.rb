class Location < ApplicationRecord

  def self.show(precision = 4, number = 'ALL', add_cp = false,
                year = DateTime.now.in_time_zone.year)
    data = {}

    if number.to_s.casecmp('all').zero?
      list = Location.all
    elsif number.to_s !~ /^\d+$/
      return {}
    else
      list = Location.where(number: number)
    end

    if add_cp
      Distance.getAllCheckpointInformation(year).each do |checkpoint|
        cp = checkpoint[:longname]
        data[cp] = {}
        data[cp][:time] = nil
        data[cp][:longitude] = Location.convert(checkpoint[:longitude]).to_f\
          .round(precision).to_s
        data[cp][:latitude] = Location.convert(checkpoint[:latitude]).to_f\
          .round(precision).to_s
      end
    end

    list.each do |l|
      next unless l.time.year == year
      if data.key?(l.number)
        if data[l.number][:time] < l.time
          data[l.number][:time] = l.time
          data[l.number][:longitude] = Location.convert(l.longitude).to_f\
            .round(precision).to_s
          data[l.number][:latitude] = Location.convert(l.latitude).to_f\
            .round(precision).to_s
        end
      else
        data[l.number] = {}
        data[l.number][:time] = l.time
        data[l.number][:longitude] = l.longitude.to_f.round(precision).to_s
        data[l.number][:latitude] = l.latitude.to_f.round(precision).to_s
      end
    end
    data
  end

  def self.uniq_location(precision, number = 'ALL', add_cp = false,
                    year = DateTime.now.in_time_zone.year)
    accuracy = 2.0
    (1..precision).each {|count| accuracy /= 10 }

    list = Location.show(precision, number, add_cp, year)
    found = {}
    data = {}

    key_list = list.keys.select {|k| k if k.is_a?(String)}
    key_list += list.keys.select {|k| k if k.is_a?(Integer)}.sort
    
    key_list.each do |key|
      hash = list[key]
      location = hash[:longitude] + ',' + hash[:latitude]
      count = 0
      while found.key?(location)
        count += 1
        if count % 2 == 0
          hash[:longitude] = (hash[:longitude].to_f - accuracy.to_f).to_s
          hash[:latitude] = (hash[:latitude].to_f + accuracy.to_f).to_s
        else
          hash[:longitude] = (hash[:longitude].to_f + accuracy.to_f).to_s
        end
        location = hash[:longitude] + ',' + hash[:latitude]
      end

      found[location] = true

      data[key] = {}
      data[key][:time] = hash[:time]
      data[key][:longitude] = hash[:longitude]
      data[key][:latitude] = hash[:latitude]
    end

    data 
  end
  private
  def self.convert(degree)
    converted = degree

    if degree =~ /^(\d+)o\s*(\d+)'\s*([\d\.]+)"\s*([NSEWnsew]*)\s*$/
      d = $1.to_f
      m = $2.to_f
      s = $3.to_f
      p = $4
      converted = d +(m + s / 60)/60
      converted *= -1 if p.casecmp('s').zero?
      converted *= -1 if p.casecmp('w').zero?
    end

    return converted
  end
end
