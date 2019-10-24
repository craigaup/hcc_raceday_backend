namespace :read_non_starters_list do
  desc 'Read Non Starters'
  task :all => :environment do
    filename = File.join('/tmp', 'nonstarters', 'nonstarters.json')
    if File.exist?(filename)
      json_text = File.readlines(filename).join
      non_starters_list = JSON.parse(json_text)

      Datum.setValue('lastcanoenumber', non_starters_list['lastNumber']) if non_starters_list.key?('lastNumber')
      user = User.find_by(username: 'start')
      checkpoint = Distance.find_by(longname: 'Start')

      if non_starters_list.key?('computerVersion') && !user.nil? && !checkpoint.nil?
        non_starters_list['computerVersion'].each do |c|
          Craft.create(number: c, 
                       year: DateTime.now.in_time_zone.year,
                       status: 'DNS',
                       time: DateTime.now.in_time_zone,
                       user_id: user.id,
                       checkpoint_id: checkpoint.id,
                       entered: DateTime.now.in_time_zone)
        end
      end
    end
  end
end

