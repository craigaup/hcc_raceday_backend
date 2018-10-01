require 'test_helper'

class Api::V2017::CanoesControllerTest < ActionDispatch::IntegrationTest
  test "should get first" do
    get api_v2017_canoes_first_url
    assert_response :success
  end

  test "should get last" do
    get api_v2017_canoes_last_url
    assert_response :success
  end

  # test "should get add" do
  #   get api_v2017_canoes_add_url
  #   assert_response :success
  # end

end
