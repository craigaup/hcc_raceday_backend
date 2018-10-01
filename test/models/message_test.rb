require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  def setup
    %i[one two].each do |sym|
      message = messages(sym)
      message.year = DateTime.now.in_time_zone.year
      message.message_time = DateTime.now.in_time_zone
      message.entered = DateTime.now.in_time_zone + 1.minute
      message.displayed = nil
      message.validtil = DateTime.now.in_time_zone + 12.hours
      message.save
    end
    
    @message = messages(:one)
  end

  test 'should be valid' do
    pp @message.errors unless @message.valid?
#byebug
    assert @message.valid?

    %i[one two].each do |sym|
      assert messages(sym).valid?
    end
  end

  test 'self.get_messages' do
    assert_equal 2, Message.get_messages('All').size
    assert_equal 1, Message.get_messages('100').size
  end

  # test 'self.' do
  # test 'self.' do
  #  Craft.send(:public, :getTimeFormat)
  # byebug
  # end
end
