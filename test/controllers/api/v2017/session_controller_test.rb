require 'test_helper'

class Api::V2017::SessionControllerTest < ActionDispatch::IntegrationTest
  test "should get login" do
    get api_v2017_session_login_url
    assert_response :success
  end

  test "should get logout" do
    get api_v2017_session_logout_url
    assert_response :success
  end

end
