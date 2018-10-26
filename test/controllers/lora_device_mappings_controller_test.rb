require 'test_helper'

class LoraDeviceMappingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @lora_device_mapping = lora_device_mappings(:one)
  end

  test "should get index" do
    get lora_device_mappings_url
    assert_response :success
  end

  test "should get new" do
    get new_lora_device_mapping_url
    assert_response :success
  end

  test "should create lora_device_mapping" do
    assert_difference('LoraDeviceMapping.count') do
      post lora_device_mappings_url, params: { lora_device_mapping: { device_registration: @lora_device_mapping.device_registration, number: @lora_device_mapping.number } }
    end

    assert_redirected_to lora_device_mapping_url(LoraDeviceMapping.last)
  end

  test "should show lora_device_mapping" do
    get lora_device_mapping_url(@lora_device_mapping)
    assert_response :success
  end

  test "should get edit" do
    get edit_lora_device_mapping_url(@lora_device_mapping)
    assert_response :success
  end

  test "should update lora_device_mapping" do
    patch lora_device_mapping_url(@lora_device_mapping), params: { lora_device_mapping: { device_registration: @lora_device_mapping.device_registration, number: @lora_device_mapping.number } }
    assert_redirected_to lora_device_mapping_url(@lora_device_mapping)
  end

  test "should destroy lora_device_mapping" do
    assert_difference('LoraDeviceMapping.count', -1) do
      delete lora_device_mapping_url(@lora_device_mapping)
    end

    assert_redirected_to lora_device_mappings_url
  end
end
