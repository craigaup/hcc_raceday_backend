namespace :finishers_list do
  desc 'Finishing times'
  task :save_json => :environment do
    info = {}

    Craft.getAllCheckpointInfo['Finish'].each do |hash|
      next if hash.nil?
      c = hash['IN']
      next if c.status == 'DISQ'
      next if c.status == 'DNS'

      info[c.number] = {
        time: c.time,
        distance: (c.checkpoint.distance.to_f * 1000).to_i,
        status: c.status,
        checkpoint: c.checkpoint.checkpoint
      }
    end

    date = DateTime.now.in_time_zone.year
    filename = "data/FinshInfo_#{ENV['RAILS_ENV']}_#{date}.json"
    File.open(filename, 'w') do |f|
      f.write(info.to_json)
    end

    puts "Written '#{filename}'"
  end
end
