require 'test_helper'

class Api::V2017::StatusControllerTest < ActionDispatch::IntegrationTest
  test "should get types" do
    get api_v2017_status_types_url
    assert_response :success
  end

end
