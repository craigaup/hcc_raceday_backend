require 'test_helper'

class Api::V2018::LoraControllerTest < ActionDispatch::IntegrationTest
  test "should get send" do
    get api_v2018_lora_send_url
    assert_response :success
  end

end
