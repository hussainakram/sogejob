namespace :indeed_scraper do
  desc "Scrape Jobs From Indeed"
  task :scrape, [:country, :location, :search_term, :page_number] => [:environment] do |task, args|
    IndeedScraper.scrape_data(args[:country], args[:location], args[:search_term], args[:page_number] || 1)
  end
end
