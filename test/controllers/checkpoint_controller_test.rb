require 'test_helper'

class CheckpointControllerTest < ActionDispatch::IntegrationTest
  test "should get overview" do
    get checkpoint_overview_url
    assert_response :success
  end

  test "should get info" do
    get checkpoint_info_url('Alpha')
    assert_response :success
  end

end
