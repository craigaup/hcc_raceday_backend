require 'test_helper'

class DistanceTest < ActiveSupport::TestCase
  def setup
    %i[Start Alpha Bravo Charlie Delta Echo Foxtrot Golf Hotel India Juliet 
       Kilo Lima Pitstop Mike November Spencer Oscar Papa Quebec Sierra Tango 
       Finish].each do |sym|
         d = distances(sym)
         d.year = DateTime.now.in_time_zone.year
         d.save
    end

    @newcheckpoint = Distance.create(year: 2017,
                                    checkpoint: 'Z',
                                    distance: 120,
                                    longname: 'Zulu',
                                    duesoonfrom: nil,
                                    latitude: nil,
                                    longitude: nil)

    @distance = distances(:Finish)
  end

  test 'should be valid' do
    pp @distance.errors unless @distance.valid?
    assert @distance.valid?

    %i[Start Alpha Bravo Charlie Delta Echo Foxtrot Golf Hotel India Juliet 
       Kilo Lima Pitstop Mike November Spencer Oscar Papa Quebec Sierra Tango 
       Finish].each do |sym|
      assert distances(sym).valid?
    end
  end

  test 'self.getAllCheckpointInformation' do
    dists = Distance.getAllCheckpointInformation

    assert_equal dists.map {|d| d[:shortname] }.sort, ["A",
                                                           "B",
                                                           "C",
                                                           "D",
                                                           "E",
                                                           "F",
                                                           "FIN",
                                                           "G",
                                                           "H",
                                                           "I",
                                                           "J",
                                                           "K",
                                                           "L",
                                                           "M",
                                                           "N",
                                                           "O",
                                                           "P",
                                                           "PIT",
                                                           "Q",
                                                           "S",
                                                           "SP",
                                                           "ST",
                                                           "T"]

    assert_equal dists[0].keys, \
      [:id, :shortname, :longname, :distance, :duesoonfrom, :latitude,
       :longitude]

    assert_equal Distance.getAllCheckpointInformation(2017),
      [{id: @newcheckpoint.id,
        shortname: 'Z',
        longname: 'Zulu',
        distance: 120.to_s,
        duesoonfrom: nil,
        latitude: nil,
       longitude: nil}]

  end

  test 'self.findCheckpointEntry' do
    assert_nil Distance.findCheckpointEntry('Zulu')
    assert_not_nil Distance.findCheckpointEntry('Zulu',2017)

    assert_nil Distance.findCheckpointEntry('Alpha', 2017)
    assert_equal Distance.findCheckpointEntry('Alpha'), distances(:Alpha)
    assert_equal Distance.findCheckpointEntry('A'), distances(:Alpha)
  end

  test 'self.getCheckpointMapping' do
    chk = { 10 => 'a', 11 => 'b', 12 => 'c', 13 => 'd', 14 => 'e'}
    tmpchk = chk
    assert_equal Distance.getCheckpointMapping(tmpchk), chk

    tmpchk = []
    chk.each do |id, chk|
      tmpchk[id] = chk
    end
    assert_equal Distance.getCheckpointMapping(tmpchk), chk

  end

end
