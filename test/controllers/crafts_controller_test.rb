require 'test_helper'

class CraftsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @craft = crafts(:one)
  end

  test "should get index" do
    get crafts_url
    assert_response :success
  end

  test "should get new" do
    get new_craft_url
    assert_response :success
  end

  test "should create craft" do
    assert_difference('Craft.count') do
      post crafts_url, params: { craft: { entered: @craft.entered, number: @craft.number, status: @craft.status, time: @craft.time, user_id: @craft.user_id, year: @craft.year } }
    end

    assert_redirected_to craft_url(Craft.last)
  end

  test "should show craft" do
    get craft_url(@craft)
    assert_response :success
  end

  test "should get edit" do
    get edit_craft_url(@craft)
    assert_response :success
  end

  test "should update craft" do
    patch craft_url(@craft), params: { craft: { entered: @craft.entered, number: @craft.number, status: @craft.status, time: @craft.time, user_id: @craft.user_id, year: @craft.year } }
    assert_redirected_to craft_url(@craft)
  end

  test "should destroy craft" do
    assert_difference('Craft.count', -1) do
      delete craft_url(@craft)
    end

    assert_redirected_to crafts_url
  end
end
