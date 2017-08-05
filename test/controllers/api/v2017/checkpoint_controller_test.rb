require 'test_helper'

class Api::V2017::CheckpointControllerTest < ActionDispatch::IntegrationTest
  test "should get in" do
    get api_v2017_checkpoint_in_url
    assert_response :success
  end

  test "should get out" do
    get api_v2017_checkpoint_out_url
    assert_response :success
  end

  test "should get withdraw" do
    get api_v2017_checkpoint_withdraw_url
    assert_response :success
  end

  test "should get history" do
    get api_v2017_checkpoint_history_url
    assert_response :success
  end

end
