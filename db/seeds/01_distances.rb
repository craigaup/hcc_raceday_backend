distances = {
  'ST': '0', 'A': '12.4', 'B': '17.9', 'C': '24.2', 'D': '31.2',
  'E': '40.8', 'F': '47.4', 'G': '54', 'H': '59', 'I': '65', 'J': '71',
  'K': '77', 'L': '81.6', 'PIT': '', 'M': '88.2', 'N': '93.5',
  'SP': '98.5', 'O': '98.5', 'P': '102.5', 'Q': '106.2', 'S': '109.5',
  'T': '110', 'FIN': '111',}

latlong = {
  'ST': ['33o 36\' 8.04" S','150o 49\' 11.28" E'],
  'A': ['33o 33\' 38.52" S','150o 53\' 24.78" E'],
  'B': ['33o 30\' 45.18" S','150o 53\' 53.7" E'],
  'C': ['33o 30\' 30.18" S','150o 55\' 37.98" E'],
  'D': ['33o 30\' 0.06" S','150o 52\' 18.18" E'],
  'E': ['33o 27\' 45.9" S','150o 54\' 7.32" E'],
  'F': ['33o 26\' 5.5464" S','150o 54\' 5.4858" E'],
  'G': ['33o 25\' 48.36" S','150o 55\' 18.66" E'],
  'H': ['33o 25\' 41.16" S','150o 56\' 58.32" E'],
  'I': ['33o 23\' 47.4" S','150o 58\' 55.32" E'],
  'J': ['33o 24\' 1.5" S','150o 59\' 53.76" E'],
  'K': ['33o 25\' 42.24" S','151o 2\' 12.3" E'],
  'L': ['33o 27\' 6.18" S','151o 3\' 49.68" E'],
  'PIT': ['33o 26\' 51.72" S','151o 4\' 41.76" E'],
  'M': ['33o 28\' 25.74" S','151o 5\' 17.22" E'],
  'N': ['33o 27\' 54" S','151o 7\' 10.14" E'],
  'O': ['33o 27\' 44.82" S','151o 9\' 24.84" E'],
  'SP': ['33o 27\' 36.18" S','151o 8\' 53.7" E'],
  'P': ['33o 29\' 14.82" S','151o 9\' 7.02" E'],
  'Q': ['33o 30\' 48.84" S','151o 9\' 38.1" E'],
  'S': ['33o 30\' 49.92" S','151o 10\' 27.24" E'],
  'T': ['33o 31\' 25.32" S','151o 11\' 1.68" E'],
  'FIN': ['33o 32\' 3.66" S','151o 11\' 52.86" E']}

checkpointNames = {'ST': 'Start', 'A': 'Alpha', 'B': 'Bravo', 'C': 'Charlie',
                   'D': 'Delta', 'E': 'Echo', 'F': 'Foxtrot', 'G': 'Golf',
                   'H': 'Hotel', 'I': 'India', 'J': 'Juliet', 'K': 'Kilo',
                   'L': 'Lima', 'PIT': 'Pitstop', 'M': 'Mike', 'N': 'November',
                   'O': 'Oscar', 'SP': 'Spencer', 'P': 'Papa', 'Q': 'Quebec',
                   'S': 'Sierra', 'T': 'Tango', 'FIN': 'Finish'}

duesoonFrom = {'A': 'ST', 'B': 'A', 'C': 'B', 'D': 'C', 'E': 'D', 'F': 'E',
               'G': 'F', 'H': 'G', 'I': 'H', 'J': 'I', 'K': 'J', 'L': 'K',
               'M': 'L', 'N': 'M', 'SP': 'M', 'O': 'M', 'P': 'O', 'Q': 'P',
               'S': 'Q', 'T': 'Q', 'FIN': 'Q'}

distances.each do |checkpoint, distance|
  tmpchkpt = Distance.find_by(checkpoint: checkpoint,
                           year: DateTime.now.in_time_zone.year)
  longname = checkpointNames[checkpoint]
  duesoon = ''
  duesoon = duesoonFrom[checkpoint] if duesoonFrom.key?(checkpoint)
  lat = latlong[checkpoint][0]
  long = latlong[checkpoint][1]
  if tmpchkpt.nil? then
    print "INFO: Creating checkpoint #{checkpoint} at distance #{distance}\n"
    Distance.create(checkpoint: checkpoint,
                    year: DateTime.now.in_time_zone.year,
                    distance: distance, longname: longname,
                    duesoonfrom: duesoon, latitude: lat, longitude: long)
  else
    updated = false
    if tmpchkpt.distance != distance
      tmpchkpt.distance = distance
      updated = true
    end

    if tmpchkpt.longname != longname
      tmpchkpt.longname = longname
      updated = true
    end

    if tmpchkpt.duesoonfrom != duesoon
      tmpchkpt.duesoonfrom = duesoon
      updated = true
    end

    if tmpchkpt.latitude != lat
      tmpchkpt.latitude = lat
      updated = true
    end

    if tmpchkpt.longitude != long
      tmpchkpt.longitude = long
      updated = true
    end

    if updated
      print "INFO: Updating checkpoint #{checkpoint} at distance #{distance}\n"
      tmpchkpt.save
    end
  end
end
