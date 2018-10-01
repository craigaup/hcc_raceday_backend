# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in\
  # alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def my_assert_equal(expected, actual, message = nil)
    if expected.nil? && message.nil?
      assert_nil actual
    elsif expected.nil?
      assert_nil actual, message
    elsif !message.nil?
      assert_equal expected, actual
    else
      assert_equal expected, actual, message
    end
  end

  def my_assert_not_equal(expected, actual, message = nil)
    if expected.nil? && message.nil?
      assert_not_nil actual
    elsif expected.nil?
      assert_not_nil actual, message
    elsif !message.nil?
      assert_not_equal expected, actual
    else
      assert_not_equal expected, actual, message
    end
  end

  def check_validity(check_object, check_value, valid_list, invalid_list)
    assert check_object.valid?, 'Object should be valid'

    invalid_list.each do |text|
      check_object[check_value] = text
      assert_not check_object.valid?, \
        "Setting #{ check_value } to '#{ text.inspect }' should " \
        + "make it invalid"

    end

    valid_list.each do |text|
      check_object[check_value] = text
      assert check_object.valid?, \
        "Setting #{ check_value } to '#{ text.inspect }' should " \
        + "make it valid"

    end
  end
end

class ActionController::TestCase
  include Devise::Test::ControllerHelpers
end

class ActionDispatch::IntegrationTest
  def test_users
#    @nonpriv_user = users(:one)
#    @race_admin_user = users(:four)
#    @admin_user = users(:three)
#    @treasurer_user = users(:treasurer)
#    @race_committee_user = users(:race_committee)
  end

  def sign_in(user)
    post user_session_path \
      'user[email]'    => user.email,
      'user[password]' => 'passw0rd!'
  end

  def sign_out
    delete destroy_user_session_path
  end

  def get_access_tests(allow_list, not_allowed_list, url, options = {})
    # If not_allowed_list is nil then don't check for not logged in
    # Meaning if you want to be logged in but don't care about as what
    # role then just use an empty array ( [] )
    # Options: 
    #    :nonlogin_redirect - url to redirect if not logged in
    #                      - defaults to login page
    #    :not_authorised_redirect - url to redirect if not allowed
    #                      - default to root page
    #    :nonlogin_flash_notice - expected message if not logged in
    #                      - default not checked
    #    :not_authorised_flash_notice - expected message if not logged in
    #                      - default not checked

    options = {} if options.nil?
    options[:nonlogin_redirect] = new_user_session_url unless \
      options.key?(:nonlogin_redirect)
    options[:not_authorised_redirect] = root_url unless \
      options.key?(:not_authorised_redirect)

    raise "allow_list must be an array" if allow_list.nil?

    sign_out

    get url

    if not_allowed_list.nil?
      assert_response :success, 'Not logged in should return page'
    else
      assert_redirected_to(options[:nonlogin_redirect],
                           'Not logged in should redirect to login page')
      my_assert_equal(options[:nonlogin_flash_notice], flash[:notice]) unless \
        options[:nonlogin_flash_notice].nil?

      not_allowed_list = [not_allowed_list] unless not_allowed_list.is_a?(Array)
      not_allowed_list.each do |user|
        sign_out
        sign_in(user)
        get url

        assert_redirected_to(options[:not_authorised_redirect],
                             (user.nil? ? 'nil' : user&.name) \
                             + " shouldn't be allowed to access")
        my_assert_equal(options[:not_authorised_flash_notice],
                     flash[:notice]) unless \
          options[:not_authorised_flash_notice].nil?
      end
    end

    allow_list = [allow_list] unless allow_list.is_a?(Array)
    allow_list.each do |user|
      sign_out
      sign_in(user)
      get url

      assert_response(:success, (user.nil? ? 'nil' : user&.name) \
                               + ' should be able to access' + "\n" \
                               + '  - ' + flash[:notice] )
    end
    sign_out
  end

  def post_no_access_tests(not_allow_list, url, test_data, options = nil)
    # Options: 
    #    :nonlogin_redirect - url to redirect if not logged in
    #                      - defaults to login page
    #    :not_authorised_redirect - url to redirect if not allowed
    #                      - default to root page
    #

    options = {} if options.nil?
    options[:nonlogin_redirect] = new_user_session_url unless \
      options.key?(:nonlogin_redirect)
    options[:not_authorised_redirect] = root_url unless \
      options.key?(:not_authorised_redirect)

    sign_out
    post url, params: test_data

    assert_redirected_to(options[:nonlogin_redirect],
                         'Not logged in should redirect to login page')

    not_allow_list = [not_allow_list] unless not_allow_list.is_a?(Array)
    not_allow_list.each do |user|
      sign_out
      sign_in(user)

      post url, params: test_data

      assert_redirected_to(options[:not_authorised_redirect],
                           (user.nil? ? 'nil' : user&.name) \
                           + " shouldn't be allowed to post")
    end
    sign_out
  end

  def patch_no_access_tests(not_allow_list, url, test_data, options = nil)
    # Options: 
    #    :nonlogin_redirect - url to redirect if not logged in
    #                      - defaults to login page
    #    :not_authorised_redirect - url to redirect if not allowed
    #                      - default to root page
    #

    options = {} if options.nil?
    options[:nonlogin_redirect] = new_user_session_url unless \
      options.key?(:nonlogin_redirect)
    options[:not_authorised_redirect] = root_url unless \
      options.key?(:not_authorised_redirect)

    sign_out
    patch url, params: test_data

    assert_redirected_to(options[:nonlogin_redirect],
                         'Not logged in should redirect to login page')

    not_allow_list = [not_allow_list] unless not_allow_list.is_a?(Array)
    not_allow_list.each do |user|
      sign_out
      sign_in(user)

      patch url, params: test_data

      assert_redirected_to(options[:not_authorised_redirect],
                           (user.nil? ? 'nil' : user&.name) \
                           + " shouldn't be allowed to patch")
    end
    sign_out
  end

  def delete_no_access_tests(not_allow_list, url, options = nil)
    # Options: 
    #    :nonlogin_redirect - url to redirect if not logged in
    #                      - defaults to login page
    #    :not_authorised_redirect - url to redirect if not allowed
    #                      - default to root page
    #

    options = {} if options.nil?
    options[:nonlogin_redirect] = new_user_session_url unless \
      options.key?(:nonlogin_redirect)
    options[:not_authorised_redirect] = root_url unless \
      options.key?(:not_authorised_redirect)

    sign_out
    delete url

    assert_redirected_to(options[:nonlogin_redirect],
                         'Not logged in should redirect to login page')

    not_allow_list = [not_allow_list] unless not_allow_list.is_a?(Array)
    not_allow_list.each do |user|
      sign_out
      sign_in(user)

      delete url

      assert_redirected_to(options[:not_authorised_redirect],
                           (user.nil? ? 'nil' : user&.name) \
                           + " shouldn't be allowed to patch")
    end
    sign_out
  end
end
