require "application_system_test_case"

class ScrapersTest < ApplicationSystemTestCase
  setup do
    @scraper = scrapers(:one)
  end

  test "visiting the index" do
    visit scrapers_url
    assert_selector "h1", text: "Scrapers"
  end

  test "creating a Scraper" do
    visit scrapers_url
    click_on "New Scraper"

    fill_in "Http method", with: @scraper.http_method
    check "Proxy usage" if @scraper.proxy_usage
    fill_in "Thread size", with: @scraper.thread_size
    click_on "Create Scraper"

    assert_text "Scraper was successfully created"
    click_on "Back"
  end

  test "updating a Scraper" do
    visit scrapers_url
    click_on "Edit", match: :first

    fill_in "Http method", with: @scraper.http_method
    check "Proxy usage" if @scraper.proxy_usage
    fill_in "Thread size", with: @scraper.thread_size
    click_on "Update Scraper"

    assert_text "Scraper was successfully updated"
    click_on "Back"
  end

  test "destroying a Scraper" do
    visit scrapers_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Scraper was successfully destroyed"
  end
end
