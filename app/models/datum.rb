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
    value = nil
    Datum.where('year = ?',year.to_s).each do |tmpdata|
      next unless tmpdata.key?('key')
      value = tmpdata if tmpdata['key'] == key
    end

    return nil if value.nil?
    
    value.data
  end
end
