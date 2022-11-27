# frozen_string_literal: true

require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1800, 1000]

  # driven_by :selenium, using: :chrome, screen_size: [1800, 1000]

  fixtures :all
  Capybara.default_max_wait_time = 15 # Seconds

  # Don't put this in a setup {} block! Call manually in every single test
  def sign_in_test_user
    visit root_path
    assert_text('Remember me')
    fill_in 'Username', with: 'test'
    fill_in 'Password', with: 'test_password'
    click_on 'Sign in'
    assert_text('Sign out')
  end

  def assert_on_homepage
    assert_text('New Application')
  rescue MiniTest::Assertion
    raise
  end

  def assert_in_homepage_table(...)
    within('.applications-table') { assert_text(...) }
  rescue MiniTest::Assertion
    raise
  end

  def assert_not_in_homepage_table(...)
    within('.applications-table') { assert_no_text(...) }
  rescue MiniTest::Assertion
    raise
  end

  def application_type=(application_type)
    accept_confirm do
      select application_type, from: 'application_application_type_id'
    end
  end

  def application_council
    find(:field, 'application_council_name')[:value]
  end

  def application_council=(council)
    select council, from: 'application_council_name'
  end

  def new_application_council(council)
    fill_in 'application_council_name', with: council
  end

  def application_applicant
    find(:field, 'application_applicant_name')[:value]
  end

  def application_applicant=(applicant)
    select applicant, from: 'application_applicant_name'
  end

  def new_application_applicant(applicant)
    fill_in 'application_applicant_name', with: applicant
  end

  def application_owner
    find(:field, 'application_owner_name')[:value]
  end

  def application_owner=(owner)
    select owner, from: 'application_owner_name'
  end

  def new_application_owner(owner)
    fill_in 'application_owner_name', with: owner
  end

  def application_contact
    find(:field, 'application_client_name')[:value]
  end

  def application_contact=(contact)
    select contact, from: 'application_client_name'
  end

  def new_application_contact(contact)
    fill_in 'application_client_name', with: contact
  end

  def save_application
    click_on 'Save'
  end

  def assert_can_select(text, from:)
    assert_selector("##{from} option[value='#{text}']", visible: :all)
  rescue MiniTest::Assertion
    raise
  end

  def edit_application(reference_number)
    assert_text reference_number
    find("#row-#{reference_number}").click
    sleep(4)
    assert_text 'Administration'
  end

  # Use like
  #   assert_field_has_value('#application_reference_number', 'Q8003')
  def assert_field_has_value(id, str)
    assert_equal(find(id)[:value], str)
  rescue MiniTest::Assertion
    raise
  end

  # Use like
  #   assert_datalist_option_exists('clients', 'applicant1 from firm1')
  def assert_datalist_option_exists(id, value)
    assert_selector("##{id} option[value='#{value}']", visible: :all)
  rescue MiniTest::Assertion
    raise
  end
end
