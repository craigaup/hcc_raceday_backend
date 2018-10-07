require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test 'should be valid' do
    %i[100St 101St 102St 100A 101A 100B].each do |sym|
      assert locations(sym).valid?
    end
  end

  test 'return_locations' do
    one = locations('100B'.to_sym)
    two = locations('101A'.to_sym)
    three = locations('102St'.to_sym)
    four = locations('103St'.to_sym)
    five = locations('104St'.to_sym)

    precision = 4

    output = { 100 => { time: one.time,
                        latitude: one.latitude.to_f.round(precision).to_s,
                        longitude: one.longitude.to_f.round(precision).to_s },
               101 => { time: two.time,
                        latitude: two.latitude.to_f.round(precision).to_s,
                        longitude: two.longitude.to_f.round(precision).to_s },
               102 => { time: three.time,
                        latitude: three.latitude.to_f.round(precision).to_s,
                        longitude: three.longitude.to_f.round(precision).to_s },
               103 => { time: four.time,
                         latitude: four.latitude.to_f.round(precision).to_s,
                         longitude: four.longitude.to_f.round(precision).to_s },
               104 => { time: five.time,
                         latitude: five.latitude.to_f.round(precision).to_s,
                         longitude: five.longitude.to_f.round(precision).to_s }
             }

    assert_equal output, Location.show(precision, 'ALL')
    assert_equal output, Location.show(precision, 'AlL')
    assert_equal output, Location.show

    o = {100 => output[100]}
    assert_equal o, Location.show(precision, 100)
    assert_equal o, Location.show(precision, '100')
    assert_equal o, Location.show(precision, '100')
    
    o = {}
    assert_equal o, Location.show(precision, 'fred')

    o = {
         "Start"=>{:time=>nil, :longitude=>"150.8198", :latitude=>"-33.6022"},
         "Alpha"=>{:time=>nil, :longitude=>"150.8902", :latitude=>"-33.5607"},
         "Bravo"=>{:time=>nil, :longitude=>"150.8983", :latitude=>"-33.5126"},
         "Charlie"=>{:time=>nil, :longitude=>"150.9272", :latitude=>"-33.5084"},
         "Delta"=>{:time=>nil, :longitude=>"150.8717", :latitude=>"-33.5"},
         "Echo"=>{:time=>nil, :longitude=>"150.902", :latitude=>"-33.4628"},
         "Foxtrot"=>{:time=>nil, :longitude=>"150.9015", :latitude=>"-33.4349"},
         "Golf"=>{:time=>nil, :longitude=>"150.9219", :latitude=>"-33.4301"},
         "Hotel"=>{:time=>nil, :longitude=>"150.9495", :latitude=>"-33.4281"},
         "India"=>{:time=>nil, :longitude=>"150.982", :latitude=>"-33.3965"},
         "Juliet"=>{:time=>nil, :longitude=>"150.9983", :latitude=>"-33.4004"},
         "Kilo"=>{:time=>nil, :longitude=>"151.0368", :latitude=>"-33.4284"},
         "Lima"=>{:time=>nil, :longitude=>"151.0638", :latitude=>"-33.4517"},
         "Pitstop"=>{:time=>nil, :longitude=>"151.0783", :latitude=>"-33.4477"},
         "Mike"=>{:time=>nil, :longitude=>"151.0881", :latitude=>"-33.4738"},
         "November"=>{:time=>nil, :longitude=>"151.1195", :latitude=>"-33.465"},
         "Spencer"=>{:time=>nil, :longitude=>"151.1483", :latitude=>"-33.4601"},
         "Oscar"=>{:time=>nil, :longitude=>"151.1569", :latitude=>"-33.4625"},
         "Papa"=>{:time=>nil, :longitude=>"151.152", :latitude=>"-33.4875"},
         "Quebec"=>{:time=>nil, :longitude=>"151.1606", :latitude=>"-33.5136"},
         "Sierra"=>{:time=>nil, :longitude=>"151.1742", :latitude=>"-33.5139"},
         "Tango"=>{:time=>nil, :longitude=>"151.1838", :latitude=>"-33.5237"},
         "Finish"=>{:time=>nil, :longitude=>"151.198", :latitude=>"-33.5344"},
         100=>{:time=>'Sun, 07 Oct 2018 15:27:49 UTC'.to_datetime.in_time_zone,
               :longitude=>"150.8983", :latitude=>"-33.5126"},
         101=>{:time=>'Sun, 07 Oct 2018 15:25:49 UTC'.to_datetime.in_time_zone,
               :longitude=>"150.8902", :latitude=>"-33.5607"},
         102=>{:time=>'Sun, 07 Oct 2018 14:27:49 UTC,'.to_datetime.in_time_zone,
               :longitude=>"150.8198", :latitude=>"-33.6022"},
         103=>{:time=>'Sun, 07 Oct 2018 15:27:49 UTC,'.to_datetime.in_time_zone,
               :longitude=>"150.8198", :latitude=>"-33.6022"},
         104=>{:time=>'Sun, 07 Oct 2018 15:27:49 UTC,'.to_datetime.in_time_zone,
               :longitude=>"150.8198", :latitude=>"-33.6022"}
    }
    ou = Location.show(precision, 'ALL', true)

    ou.keys do |key|
      assert_equal o[key], ou[key]
    end
  end

  test 'unique location' do
    one = locations('100B'.to_sym)
    two = locations('101A'.to_sym)
    three = locations('102St'.to_sym)
    four = locations('103St'.to_sym)
    five = locations('104St'.to_sym)

    accuracy = '0.0002'
    precision = 4

    output = { 100 => { time: one.time,
                        latitude: one.latitude.to_f.round(precision).to_s,
                        longitude: one.longitude.to_f.round(precision).to_s },
               101 => { time: two.time,
                        latitude: two.latitude.to_f.round(precision).to_s,
                        longitude: two.longitude.to_f.round(precision).to_s },
               102 => { time: three.time,
                        latitude: three.latitude.to_f.round(precision).to_s,
                        longitude: three.longitude.to_f.round(precision).to_s },
               103 => { time: four.time,
                        latitude: four.latitude.to_f.round(precision).to_s,
                        longitude: (four.longitude.to_f.round(precision) \
                                    + accuracy.to_f).to_s  },
               104 => { time: five.time,
                        latitude: (five.latitude.to_f.round(precision) \
                                   + accuracy.to_f).to_s,
                        longitude: (five.longitude.to_f.round(precision) \
                                   ).to_s
                      }
             }

    assert_equal output[103], Location.uniq_location(precision)[103]
    assert_equal output[104], Location.uniq_location(precision)[104]
    assert_equal output, Location.uniq_location(precision, 'ALL')
    assert_equal output, Location.uniq_location(precision, 'AlL')
    assert_equal output, Location.uniq_location(precision)

    o = {103 => output[103]}
    o[103][:longitude] = four.longitude.to_f.round(precision).to_s
    assert_equal o, Location.uniq_location(precision, 103)
    assert_equal o, Location.uniq_location(precision, '103')
    assert_equal o, Location.uniq_location(precision, '103')
    
    o = {}
    assert_equal o, Location.show(precision, 'fred')
  end
end
