require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    Distance.all.each do |d|
      d.year = DateTime.now.in_time_zone.year
      d.save
    end

    %i[one two].each do |sym|
      user = users(sym)
      user.password = 'passw0rd'
      user.password_confirmation = user.password
      unless user.save
        pp user.errors
      end
    end
    
    @user = users(:one)
  end

  test 'should be valid' do
    pp @user.errors unless @user.valid?
#byebug
    assert @user.valid?

    %i[one two].each do |sym|
      assert users(sym).valid?
    end
  end

  test 'username' do
    check_validity(@user, 'username', ['aaa', 'a'*20],
                   [nil, 'a', 'aa', 'a'*21, ' ', '    '])
  end

  test 'password and encrypt_password' do
    assert @user.valid?
    ['a'*6, 'a'*20].each do |pass|
      @user.password = pass
      @user.password_confirmation = pass
      assert @user.valid?, "#{pass} should be valid"
    end

    ['a' * 5, 'a'*21, ' ', ' '*6].each do |pass|
      @user.password = pass
      @user.password_confirmation = pass
      assert_not @user.valid?, "#{pass} should not be valid"
    end

    @user.password = 'a'*7
    @user.password_confirmation = 'a' * 8
    assert_not @user.valid?, 'Unidentical password should not be valid'

    salt = @user.salt
    encpw = @user.encrypted_password
    @user.password = nil
    @user.password_confirmation = nil

    @user.encrypt_password

    assert_equal salt, @user.salt
    assert_equal encpw, @user.encrypted_password

    @user.password = 'a'*7
    @user.password_confirmation = 'a' * 7

    @user.encrypt_password

    assert_not_equal salt, @user.salt
    assert_not_equal encpw, @user.encrypted_password
  end 

  test 'isCheckpoint?' do
    assert_not @user.isCheckpoint?

    @user.username = 'alpha'
    @user.save
    assert @user.isCheckpoint?
  end

  test 'self.authenticate' do
    assert User.authenticate(@user.username, 'passw0rd')
    assert_not User.authenticate(@user.username, 'passw0r')
  end

  test 'israceadmin?' do
    assert @user.israceadmin?
    assert @user.israceadmin?(DateTime.now.in_time_zone.year)
    assert_not @user.israceadmin?(2017)

    ouser = users(:two)
    assert_not ouser.israceadmin?
    assert_not ouser.israceadmin?(DateTime.now.in_time_zone.year)
    assert ouser.israceadmin?(2017)
  end

  test 'self.' do
  # test 'self.' do
  #  User.send(:public, :getTimeFormat)
byebug
  end
end
