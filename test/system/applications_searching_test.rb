# frozen_string_literal: true

require 'application_system_test_case'

class ApplicationsTest < ApplicationSystemTestCase
  test 'searching by application type' do
    sign_in_test_user
    assert_no_text 'RC5001'
    assert_no_text 'RC5002'
    select 'RC', from: 'type'
    click_on 'Search'
    assert_text 'RC5001'
    assert_text 'RC5002'

    # Clear the field and search again
    select 'Select Type:', from: 'type'
    click_on 'Search'
    assert_no_text 'RC5001'
    assert_no_text 'RC5002'
  end

  test 'searching by start & end date' do
    sign_in_test_user

    # Check the search datepickers are setup correctly so you can't search in the future
    # NOTE: Accept a range of 3 days, because it's too hard to try matching timezones between
    # the headless browser and ruby, and could even fail anyway if the browser loads
    # at 11:59:59pm and this test runs at 12:00:01am
    yesterday = (Time.zone.now - 1.day).strftime('%Y-%m-%d')
    today = Time.zone.now.strftime('%Y-%m-%d')
    tomorrow = (Time.zone.now + 1.day).strftime('%Y-%m-%d')
    assert_any_of_selectors(
      "#start_date[max=\"#{yesterday}\"]",
      "#start_date[max=\"#{today}\"]",
      "#start_date[max=\"#{tomorrow}\"]"
    )
    assert_any_of_selectors(
      "#end_date[max=\"#{yesterday}\"]",
      "#end_date[max=\"#{today}\"]",
      "#end_date[max=\"#{tomorrow}\"]"
    )

    april_application = applications(:application_Q1)
    april_application.update!(created_at: Date.new(2022, 4, 5))
    assert_no_text 'Q8001'

    def clear
      click_on 'clear-search'
      assert_no_text 'PC9001'
      click_on 'Search'
      assert_text 'PC9001'
    end

    # Date between
    fill_in 'start_date', with: '01/03/2022'
    fill_in 'end_date', with: '01/05/2022'
    click_on 'Search'
    assert_text 'Q8001'

    clear

    # Date == start
    fill_in 'start_date', with: '05/04/2022'
    fill_in 'end_date', with: '01/05/2022'
    click_on 'Search'
    assert_text 'Q8001'

    clear

    # Date == end
    fill_in 'start_date', with: '01/03/2022'
    fill_in 'end_date', with: '05/04/2022'
    click_on 'Search'
    assert_text 'Q8001'

    clear

    # Test that it goes away
    assert_no_text 'Q8001'
  end

  test 'start and end date outliers do not show' do
    sign_in_test_user
    assert_text 'PC9001'
    assert_text 'PC9002'

    pc1 = applications(:application_PC1)
    pc2 = applications(:application_PC2)
    pc1.update!(created_at: Date.new(1855, 4, 5)) # too old
    pc2.update!(created_at: Date.new(2500, 4, 5)) # too new

    # refresh page and check they are not there anymore
    click_on 'clear-search'
    click_on 'Search'
    assert_no_text 'PC9001'
    assert_no_text 'PC9002'
  end

  test 'clearing search parameters' do
    sign_in_test_user
    test_application = applications(:application_LG1)
    test_application.update!(description: 'Something or rather')

    select 'LG', from: 'type'
    fill_in 'start_date', with: '01/01/2022'
    fill_in 'end_date', with: '22/10/2022'
    fill_in 'search_text', with: 'something rather'

    # Post the form and check it searched properly
    click_on 'Search'
    within('.applications-table') do
      assert_text 'LG6001'
      assert_text 'Something or rather'
    end

    # Are they there?
    within('.search-form') do
      assert_text 'LG'

      # Need to use selectors for the inputs because they don't show as text to selenium
      assert_selector('option[value="LG"][selected="selected"]')
      assert_selector('#start_date[value="2022-01-01"]')
      assert_selector('#end_date[value="2022-10-22"]')
      assert_selector('#search_text[value="something rather"]')
    end

    click_on 'clear-search'
    click_on 'Search'

    # Are they gone?
    within('.search-form') do
      assert_no_selector('option[value="LG"][selected="selected"]')
      assert_no_selector('#start_date[value="2022-01-01"]')
      assert_no_selector('#end_date[value="2022-10-22"]')
      assert_no_selector('#search_text[value="something rather"]')
    end
  end

  test 'searching by text' do
    sign_in_test_user

    def text_search_and_assert(str, asserting, assert_str)
      fill_in 'search_text', with: str
      click_on 'Search'
      if asserting == 'assert'
        assert_text assert_str
      else
        assert_no_text assert_str
      end
    end

    # Reference numbers
    text_search_and_assert('LG6', 'assert', 'LG6001')
    text_search_and_assert('LG7', 'assert_no', 'LG6001')
    fill_in 'search_text', with: 'PC591'
    click_on 'Search'
    5910.upto(5919) { |n| assert_text "PC#{n}" }
    assert_no_text 'PC5909'
    assert_no_text 'PC5920'

    # Hitting the enter key also works
    fill_in 'search_text', with: 'SC4'
    find('#search_text').send_keys(:enter)
    assert_text('SC4001')
    assert_text('SC4002')

    # Location
    app = applications(:application_PC5900)
    app.update!(street_name: 'Easy street', street_number: 1234)
    text_search_and_assert('Easy', 'assert', 'PC5900')
    text_search_and_assert('ztreet', 'assert_no', 'PC5900')
    text_search_and_assert('1234', 'assert', 'PC5900')
    text_search_and_assert('234', 'assert_no', 'PC5900')

    # DA number
    app = applications(:application_PC5901)
    app.update!(development_application_number: 'DA5555')
    text_search_and_assert('DA5555', 'assert', 'PC5901')

    # Description
    app = applications(:application_PC5902)
    app.update!(description: 'Single word search')
    text_search_and_assert('single', 'assert', 'PC5902')
    app = applications(:application_PC5903)
    app.update!(description: 'Double word search')
    text_search_and_assert('Double word', 'assert', 'PC5903')

    # Suburb
    app = applications(:application_PC5904)
    suburb2 = suburbs(:suburb2)
    app.update!(suburb: suburb2)
    text_search_and_assert('SUBURB2', 'assert', 'PC5904')
    assert_text('SUBURB2, SA XXXX')
    assert_no_text('SUBURB1')

    # Council
    app = applications(:application_PC5905)
    council2 = councils(:council2)
    app.update!(council: council2)
    text_search_and_assert('council2', 'assert', 'PC5905')
    text_search_and_assert('councilzzzz', 'assert_no', 'PC5905')
    text_search_and_assert('council2 of place2', 'assert', 'PC5905')
    assert_text('council2')
    assert_no_text('council1')

    # Contact
    app = applications(:application_PC5906)
    contact2 = clients(:contact2)
    app.update!(client: contact2)
    text_search_and_assert('contact2', 'assert', 'PC5906')
    text_search_and_assert('contactzzzz', 'assert_no', 'PC5906')
    text_search_and_assert('contact2 of group2', 'assert', 'PC5906')
    assert_text('contact2')
    assert_no_text('contact1')

    # Owner
    app = applications(:application_PC5907)
    owner2 = clients(:owner2)
    app.update!(owner: owner2)
    text_search_and_assert('owner2', 'assert', 'PC5907')
    text_search_and_assert('ownerzzzz', 'assert_no', 'PC5907')
    text_search_and_assert('owner2 lastname', 'assert', 'PC5907')
    assert_text('owner2')
    assert_no_text('owner1')

    # Applicant
    app = applications(:application_PC5908)
    applicant2 = clients(:applicant2)
    app.update!(applicant: applicant2)
    text_search_and_assert('applicant2', 'assert', 'PC5908')
    text_search_and_assert('applicantzzzz', 'assert_no', 'PC5908')
    text_search_and_assert('applicant2 from firm2', 'assert', 'PC5908')
    assert_text('applicant2')
    assert_no_text('applicant1')
  end
end
