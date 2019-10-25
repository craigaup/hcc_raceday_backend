namespace :starters_list do
  desc 'Read Non Starters'
  task :load_json => :environment do
    filename = File.join('/tmp', 'hcc', 'starters.json')
    if File.exist?(filename)
      json_text = File.readlines(filename).join
      starters_list = JSON.parse(json_text)
    else
      starters_list = {}
    end

    checkpoint = Distance.find_by(longname: 'Start')
    user = User.find_by(username: 'start')

    starters_list.each do |number, time|
      time = time.to_datetime.in_time_zone
      puts "Setting Canoe #{number} as starting at #{time.hour}:#{time.min}"
      Craft.create(number: number, 
                   year: DateTime.now.in_time_zone.year,
                   status: 'OUT',
                   time: time,
                   user_id: user.id,
                   checkpoint_id: checkpoint.id,
                   entered: DateTime.now.in_time_zone)
    end
  end
end

