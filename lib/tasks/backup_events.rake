namespace :backup do
  desc 'Backs up all the data'
  task :all => :environment do
    date = DateTime.now.in_time_zone.strftime('%Y%m%d%H%M%S')
    dir_path = File.join(Rails.root, 'data', 'backup')
    Dir.mkdir(dir_path) unless File.exist?(dir_path)

    filename = "dump_#{date}.rb"
    File.open(File.join(dir_path, filename),'w') do |f|
      f.write("d_h = JSON.parse('#{Distance.all.to_json}')\n")
      f.write("d = Distance.create(d_h)\n")

      f.write("l_h = JSON.parse('#{Location.all.to_json}')\n")
      f.write("l = Location.create(l_h)\n")

      f.write("dev_h = JSON.parse('#{LoraDeviceMapping.all.to_json}')\n")
      f.write("dev = LoraDeviceMapping.create(dev_h)\n")

      f.write("u_h = JSON.parse('#{User.all.to_json}')\n")
      f.write("u = User.create(u_h)\n")

      f.write("c_h = JSON.parse('#{Craft.all.to_json}')\n")
      f.write("c = Craft.create(c_h)\n")

      f.write("da_h = JSON.parse('#{Datum.all.to_json}')\n")
      f.write("da = Datum.create(da_h)\n")

      f.write("m_h = JSON.parse('#{Message.all.to_json}')\n")
      f.write("m = Message.create(m_h)\n")

      f.write("r_h = JSON.parse('#{Raceadmin.all.to_json}')\n")
      f.write("r = Raceadmin.create(r_h)\n")
    end
  end
end
