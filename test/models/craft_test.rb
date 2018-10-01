require 'test_helper'

class CraftTest < ActiveSupport::TestCase
  def setup
    Distance.all.each do |d|
      d.year = DateTime.now.in_time_zone.year
      d.save
    end

    %i[one two oneout twoout].each do |sym|
      craft = crafts(sym)
      craft.year = DateTime.now.in_time_zone.year
      craft.save
    end
    
    @craft = crafts(:one)
  end

  test 'should be valid' do
    pp @craft.errors unless @craft.valid?
#byebug
    assert @craft.valid?

    %i[one two oneout twoout].each do |sym|
      assert crafts(sym).valid?
    end
  end

  test 'self.findMinCanoeNumber' do
    assert Craft.findMinCanoeNumber, 100
    
    Datum.setValue('firstcanoenumber', '101', 2017)
    assert Craft.findMinCanoeNumber(2017), 101

    Datum.setValue('firstcanoenumber', '101', DateTime.now.in_time_zone.year)
    assert Craft.findMinCanoeNumber, 101
  end

  test 'self.findMaxCanoeNumber' do
    assert Craft.findMaxCanoeNumber, 500
    
    Datum.setValue('firstcanoenumber', '501', 2017)
    assert Craft.findMaxCanoeNumber(2017), 501

    Datum.setValue('firstcanoenumber', '501', DateTime.now.in_time_zone.year)
    assert Craft.findMaxCanoeNumber, 501
  end

  test 'checkCanoeNumberValue and number must be a number' do
    check_validity(@craft, 'number', [100, 500, 450], 
                   [nil, 1, 550, 99, 501, 'a', ' ', ''])
  end

  test 'checkStatusIsValid' do
    check_validity(@craft, 'status',
                   ['IN', 'OUT', 'WD', 'DNS', 'Withdrawn', 'Non-Starter'], 
                   [nil, 1, 'a', 'DNF', '', ' '])
  end

  test 'year must be a number' do
    check_validity(@craft, 'year',
                   [2016, 2017, DateTime.now.in_time_zone.year], 
                   [nil, 'a', ' ', ''])
  end

  test 'entered must be a number' do
    check_validity(@craft, 'entered',
                   [DateTime.now.in_time_zone,
                    DateTime.now.in_time_zone - 1.year,
                    '4/4/16 13:00', '13:00'], 
                   [nil, 'a', ' ', ''])
  end

  test 'time must be a number' do
    check_validity(@craft, 'time',
                   [DateTime.now.in_time_zone,
                    DateTime.now.in_time_zone - 1.year,
                    '4/4/16 13:00', '13:00'], 
                   [nil, 'a', ' ', ''])
  end

  test 'self.getFieldInfo' do
    assert_equal Craft.getFieldInfo, \
      {100 => 
       {number: 100,
        checkpoint: "Alpha",
        status: "OUT",
        time: 'Tue, 04 Apr 2017 13:00:02 UTC'.to_datetime.in_time_zone,
        distance: 12400},
        101 => 
        {number: 101,
         checkpoint: "Alpha",
         status: "OUT",
         time: 'Tue, 04 Apr 2017 13:00:03 UTC'.to_datetime.in_time_zone,
         distance: 12400}}
  end

  test 'self.getStatus' do
    assert_equal Craft.getStatus(@craft.number), \
      {number: 100, checkpoint: "Alpha", status: "OUT",
       time: 'Tue, 04 Apr 2017 13:00:02 UTC'.to_datetime.in_time_zone,
       distance: 12400}
  end

  test 'self.find_last_entry' do
    tmphistory = Craft.getHistory('ALL', 'ALL', DateTime.now.in_time_zone.year)
    assert_equal Craft.find_last_entry(tmphistory, @craft.number),
      {number: 100, checkpoint: "Alpha", status: "OUT",
       time: 'Tue, 04 Apr 2017 13:00:02 UTC'.to_datetime.in_time_zone,
       distance: 12400}
  end

  test 'self.getHistory' do
    assert_equal Craft.getHistory('ALL', 'ALL',
                                  DateTime.now.in_time_zone.year), \
                 {100 => {"Alpha" => [{number: 100,
                                       checkpoint: "Alpha",
                                       status: "IN",
                                       time: 'Tue, 04 Apr 2017 13:00:00 UTC'.\
                                       to_datetime.in_time_zone,
                                       distance: 12400},
                                       {number: 100,
                                        checkpoint: "Alpha",
                                        status: "OUT",
                                        time: 'Tue, 04 Apr 2017 13:00:02 UTC'.\
                                        to_datetime.in_time_zone,
                                        distance: 12400}]},
                  101 => {"Alpha" => [{number: 101,
                                       checkpoint: "Alpha",
                                       status: "IN",
                                       time: 'Tue, 04 Apr 2017 13:00:01 UTC'.\
                                       to_datetime.in_time_zone,
                                       distance: 12400},
                                       {number: 101,
                                        checkpoint: "Alpha",
                                        status: "OUT",
                                        time: 'Tue, 04 Apr 2017 13:00:03 UTC'.\
                                        to_datetime.in_time_zone,
                                        distance: 12400}]}}
  end

  test 'self.getAllCheckpointInfo and self.overallStatus' do
    output = {}
    output['Alpha'] = []
    output['Alpha'][100] = {}
    output['Alpha'][100]['IN'] = crafts(:one)
    output['Alpha'][100]['OUT'] = crafts(:oneout)
    output['Alpha'][101] = {}
    output['Alpha'][101]['IN'] = crafts(:two)
    output['Alpha'][101]['OUT'] = crafts(:twoout)

    assert_equal output, Craft.getAllCheckpointInfo
    
    assert_equal output, Craft.overallStatus
  end

  test 'overdue?' do
    assert_not @craft.overdue?
  end

  test 'self.getData' do
    output = [crafts(:twoout), crafts(:two), crafts(:oneout), crafts(:one)]
    assert_equal output, Craft.getData('Alpha', 'ALL')
  end


  test 'self.displayCheckpointInfo' do
    output = {100=>{"IN"=>{"status"=>"IN", "time"=>"23:00:00",
                           "overdue"=>false},
                     "OUT"=>{"status"=>"OUT", "time"=>"23:00:02",
                             "overdue"=>false}},
              101=>{"IN"=>{"status"=>"IN", "time"=>"23:00:01",
                           "overdue"=>false},
                    "OUT"=>{"status"=>"OUT", "time"=>"23:00:03",
                            "overdue"=>false}}}

    assert_equal output, Craft.displayCheckpointInfo('Alpha')
  end

  test 'self.getAllCheckpointHistory' do
    output = {"Alpha"=>{100=>{:number=>100, :checkpoint=>"Alpha",
                              :status=>"OUT",
                              :time=>'Tue, 04 Apr 2017 13:00:02 UTC'\
                                      .to_datetime.in_time_zone,
                              :distance=>12400},
                        101=>{:number=>101, :checkpoint=>"Alpha",
                              :status=>"OUT",
                              :time=>'Tue, 04 Apr 2017 13:00:03 UTC'\
                                      .to_datetime.in_time_zone,
                              :distance=>12400}},
              "___timings"=>{"Alpha"=>[]},
              "___lastseen"=>{100=>"Alpha", 101=>"Alpha"},
              "___lastdata"=>{100=>crafts(:oneout),
                              101=>crafts(:twoout)},
              "___averages"=>{},
              "___overdue"=>{100=>false, 101=>false},
              "___count"=>{"Alpha"=>{"IN"=>0, "OUT"=>2, "WD"=>0}},
              "___orderedcheckpoints"=>{"Start"=>nil, "Alpha"=>"Start",
                                        "Bravo"=>"Alpha", "Charlie"=>"Bravo",
                                        "Delta"=>"Charlie", "Echo"=>"Delta",
                                        "Foxtrot"=>"Echo", "Golf"=>"Foxtrot",
                                        "Hotel"=>"Golf", "India"=>"Hotel",
                                        "Juliet"=>"India", "Kilo"=>"Juliet",
                                        "Lima"=>"Kilo", "Mike"=>"Lima",
                                        "November"=>"Mike",
                                        "Oscar"=>"November", "Papa"=>"Oscar",
                                        "Quebec"=>"Papa", "Sierra"=>"Quebec",
                                        "Tango"=>"Sierra", "Finish"=>"Tango"}}
    assert_equal output, Craft.getAllCheckpointHistory(nil)
  end
  test 'self.caclOverdue' do
    now = DateTime.now.in_time_zone
    [1, 44].each do |min|
      assert Craft.calcOverdue('OUT', now, now - 60.minutes, min * 60), \
        "#{min} minutes should be true"
    end

    assert_not Craft.calcOverdue('IN', now, now - 60.minutes, 120 * 60)

    [45, 60].each do |min|
      assert_not Craft.calcOverdue('IN', now, now - 60.minutes, min * 60), \
        "#{min} minutes should be false"
    end
  end

  test 'self.finish_info' do
    output = {100=>{:distance=>12400,
                    :time=>'Tue, 04 Apr 2017 13:00:02 UTC'.to_datetime\
                            .in_time_zone},
              101=>{:distance=>12400,
                    :time=>'Tue, 04 Apr 2017 13:00:03 UTC'.to_datetime\
                            .in_time_zone}} 

    assert_equal output, Craft.finish_info
  end

  test 'self.getTimeFormat' do
    assert_equal '3:02', Craft.getTimeFormat([1,2,3])
    assert_equal '6:05', Craft.getTimeFormat([4,5,6], false)
    assert_equal '12:11:10', Craft.getTimeFormat([10,11,12], true)
  end

  # test 'self.' do
  # test 'self.' do
  #  Craft.send(:public, :getTimeFormat)
# byebug
#   end
end
