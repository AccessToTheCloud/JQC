# frozen_string_literal: true

require 'application_system_test_case'

class ApplicationsTest < ApplicationSystemTestCase
  fixtures :applications5000, :application_types, :users

  setup { sign_in_test_user }

  test 'The pagination of applications' do
    visit applications_url

    # Check the first page shows 1000 results
    5995.upto(6000) { |n| assert_text "PC#{n}" }
    5001.upto(5005) { |n| assert_text "PC#{n}" }
    assert_no_text 'PC5000'
    assert_no_text 'PC4999'

    assert_text '1011 results available'

    # Check clicking page 2 shows next 1000 results
    within('.pagination') do
      click_on '2'
    end

    # Need to wait a bit longer for turbolinks
    wait_for_ajax
    assert_text 'PC5000'
    assert_text 'PC4999'
    assert_no_text 'PC5001'

    #byebug

    #3990.upto(4000) { |n| assert_text "PC#{n}" }
    #3001.upto(3010) { |n| assert_text "PC#{n}" }
    #2990.upto(3000) { |n| assert_no_text "PC#{n}" }


    # Check page 5 shows results 5001 to 5500

    ## Test both urls "/" and "/applications" show the applications table
    #[root_path, applications_url].each do |url|
    #visit url
    #assert_text 'Reference Number'
    ## Check all the PCs are there
    #1.upto(5) { |n| assert_text "PC#{n}" }
    ## Check all the LGs are there
    #1.upto(5) { |n| assert_text "LG#{n}" }
    #end
    ## Test that all column headers are shown
    #[
    #'Reference Number',
    #'Location',
    #'Suburb',
    #'Description',
    #'Contact',
    #'Owner',
    #'Applicant',
    #'Council',
    #'Date Created',
    #'DA No.'
    #].each { |header| assert_text header }
    ## Check all PC details are shown
    #applications.each do |a|
    #next unless a.application_type == 'PC'
    #assert_text a.reference_number
    #assert_text "#{a.lot_number} #{a.street_number} #{a.street_name}"
    #assert_text a.suburb.display_name
    #assert_text a.description
    #assert_text a.client.client_name
    #assert_text a.owner.client_name
    #assert_text a.applicant.client_name
    #assert_text a.council.name
    #assert_text a.created_at
    #assert_text a.development_application_number
    #end
    ## Check that location names display properly
    ## Test searching by application type
    #select 'LG', from: 'select_type'
    #click_on 'Search'
    #1.upto(5) { |n| assert_no_text "PC#{n}", wait: 10 }
    #1.upto(5) { |n| assert_text "LG#{n}" }
  end
end
