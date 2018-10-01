require 'test_helper'

class Api::V2017::SessionControllerTest < ActionDispatch::IntegrationTest
  def setup
    %i[one two].each do |sym|
      user = users(sym)
      user.password = 'passw0rd'
      user.password_confirmation = user.password
      unless user.save
        pp user.errors
      end
    end
  end

  test "should get login" do
    post api_v2017_session_login_url, params: {username: 'one', login_password: 'passw0rd'}
    assert_response :success
  end

  test "should get logout" do
    get api_v2017_session_logout_url
    assert_response :success
  end

end
