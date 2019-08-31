datum = { 'firstcanoenumber': '100', 'lastcanoenumber': '400',
          'setlocationatcheckpoint': 'true'}

datum.each do |key, value|
  tmpdata = Datum.find_by(key: key,
                           year: DateTime.now.in_time_zone.year)
  if tmpdata.nil? then
    Datum.create(key: key, data: value,
                 year: DateTime.now.in_time_zone.year)
  else
    tmpdata.data = value
    tmpdata.save
  end
end
