namespace :indeed_scraper do
  desc "Scrape Jobs From Indeed"
  task :scrape => [:environment] do |task, args|
    IndeedScraper.scrape_data
  end
end
