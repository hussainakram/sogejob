require 'test_helper'

class ScrapersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @scraper = scrapers(:one)
  end

  test "should get index" do
    get scrapers_url
    assert_response :success
  end

  test "should get new" do
    get new_scraper_url
    assert_response :success
  end

  test "should create scraper" do
    assert_difference('Scraper.count') do
      post scrapers_url, params: { scraper: { http_method: @scraper.http_method, proxy_usage: @scraper.proxy_usage, thread_size: @scraper.thread_size } }
    end

    assert_redirected_to scraper_url(Scraper.last)
  end

  test "should show scraper" do
    get scraper_url(@scraper)
    assert_response :success
  end

  test "should get edit" do
    get edit_scraper_url(@scraper)
    assert_response :success
  end

  test "should update scraper" do
    patch scraper_url(@scraper), params: { scraper: { http_method: @scraper.http_method, proxy_usage: @scraper.proxy_usage, thread_size: @scraper.thread_size } }
    assert_redirected_to scraper_url(@scraper)
  end

  test "should destroy scraper" do
    assert_difference('Scraper.count', -1) do
      delete scraper_url(@scraper)
    end

    assert_redirected_to scrapers_url
  end
end
