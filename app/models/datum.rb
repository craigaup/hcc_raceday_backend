class Datum < ApplicationRecord
  belongs_to :user

  def self.statusList
    [
      {shortname: 'IN', longname: 'IN', admin: false},
      {shortname: 'OUT', longname: 'OUT', admin: false},
      {shortname: 'WD', longname: 'Withdrawn', admin: true},
      {shortname: 'DNS', longname: 'Non-Starter', admin: true},
      {shortname: 'DISQ', longname: 'Disqualified', admin: true}
    ]

  end

  def self.returnValue(key, year = DateTime.now.year)
    return nil if key.nil?
    
    value = nil

    Datum.where('year = ?',year.to_s).each do |data|
      value = data if data.key.downcase == key.downcase
    end

    return nil if value.nil?
    
    value.data
  end

  def self.setValue(key, data, year = DateTime.now.year)
    return false if key.nil?

    value = nil
    Datum.where('year = ?',year.to_s).each do |data|
      value = data if data.key.downcase == key.downcase
    end

    value = Datum.new(key: key.downcase, year: year.to_s) if value.nil?
    
    value.data = data
    value.save
  end
end
