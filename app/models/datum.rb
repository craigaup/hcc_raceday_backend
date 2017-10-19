class Datum < ApplicationRecord
  belongs_to :user

  def self.statusList
    [
      {shortname: 'IN', longname: 'IN'},
      {shortname: 'OUT', longname: 'OUT'},
      {shortname: 'WD', longname: 'Withdrawn'},
      {shortname: 'DNS', longname: 'Non-Starter'}
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
