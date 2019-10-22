require 'test_helper'

class DatumTest < ActiveSupport::TestCase
  def setup
    %i[one two ].each do |sym|
      datum = data(sym)
      datum.year = DateTime.now.in_time_zone.year
      datum.save
    end
    
    @datum = data(:one)
  end

  test 'should be valid' do
    pp @datum.errors unless @datum.valid?
#byebug
    assert @datum.valid?

    %i[one two].each do |sym|
      assert data(sym).valid?
    end
  end


  test 'self.statusList' do
    output = [
      {shortname: 'IN', longname: 'IN', admin: false},
      {shortname: 'OUT', longname: 'OUT', admin: false},
      {shortname: 'WD', longname: 'Withdrawn', admin: true},
      {shortname: 'DNS', longname: 'Non-Starter', admin: true},
      {shortname: 'DISQ', longname: 'Disqualified', admin: true},
    ]

    assert_equal output, Datum.statusList
  end

  test 'self.returnValue' do
    assert_nil Datum.returnValue('MyString', 2017)
    assert_equal @datum.data, Datum.returnValue(@datum.key,
                                                DateTime.now.in_time_zone.year)
    assert_equal @datum.data, Datum.returnValue(@datum.key)
  end

  test 'self.setValue' do
    assert_not Datum.setValue(nil, 'a')

    assert Datum.setValue('a', 'b')
    assert_equal 'b', Datum.returnValue('a')

    assert Datum.setValue('a', 'c', DateTime.now.in_time_zone.year)
    assert_equal 'c', Datum.returnValue('a', DateTime.now.in_time_zone.year)

    assert Datum.setValue('a', 'd', 2017)
    assert_equal 'c', Datum.returnValue('a')
    assert_equal 'd', Datum.returnValue('a', 2017)
  end

  # test 'self.' do
  # test 'self.' do
  #   Craft.send(:public, :getTimeFormat)
  # byebug
  # end
end
