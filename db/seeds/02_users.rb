# This file should contain all the record creation needed to
# seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created
# alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, \
#                          { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#
#
# http://www.canoeclassic.asn.au/race-rules/race-classes.htm

require File.dirname(__FILE__) + '/.userinitialpass.rb'

userList = ['root', 'sydwest', 'start', 'alpha', 'bravo', 'charlie', 'delta',
            'echo', 'foxtrot', 'golf', 'hotel', 'india', 'juliett', 'kilo',
            'lima', 'pitstop', 'mike', 'november', 'oscar', 'spencer', 'papa',
            'quebec', 'sierra', 'tango', 'finish', 'craigp', 'richard', 'doug',
            'andrew', 'chris']

raceadminList = ['root', 'sydwest', 'start', 'finish', 'craigp', 'richard', 'doug', 'andrew', 'chris']
userList.each do |username|
  if User.find_by(username: username) == nil then
    if username == 'craigp' then
      name = 'Craig'
    else
      name = username.capitalize
    end

    print "INFO: Creating user #{username}\n"
    User.create(name: name, username: username,
                password: @password,
                password_confirmation: @password)
  end
end

raceadminList.each do |username|
  print "INFO: Making sure #{username} is a raceadmin\n"
  user =  User.find_by(username: username)

  if Raceadmin.where('user_id = ? AND year = ?', user.id,DateTime.now.year.to_s) == nil then
    Raceadmin.create(year: DateTime.now.year, user: user)
  end
end


