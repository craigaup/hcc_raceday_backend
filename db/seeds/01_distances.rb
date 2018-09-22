distances = {
  'ST': '0', 'A': '12.4', 'B': '17.9', 'C': '24.2', 'D': '31.2',
  'E': '40.8', 'F': '47.4', 'G': '54', 'H': '59', 'I': '65', 'J': '71',
  'K': '77', 'L': '81.6', 'PIT': '', 'M': '88.2', 'N': '93.5',
  'SP': '98.5', 'O': '98.5', 'P': '102.5', 'Q': '106.2', 'S': '109.5',
  'T': '110', 'FIN': '111',}

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
  if Distance.find_by(checkpoint: checkpoint,
                      year: DateTime.now.in_time_zone.year).nil? then
    longname = checkpointNames[checkpoint]
    print "INFO: Creating checkpoint #{checkpoint} at distance #{distance}\n"
    duesoon = ''
    duesoon = duesoonFrom[checkpoint] if duesoonFrom.key?(checkpoint)
    Distance.create(checkpoint: checkpoint,
                    year: DateTime.now.in_time_zone.year,
                    distance: distance, longname: longname,
                    duesoonfrom: duesoon)
  end
end
