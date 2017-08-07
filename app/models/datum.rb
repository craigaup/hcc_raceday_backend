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
end
