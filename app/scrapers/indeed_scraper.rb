require 'json'
require_relative "user_agents"
require_relative "city"
require 'pp'
require 'rubygems'
require 'mechanize'

class IndeedScraper
  # Invoke instance method scrape_data with given parameters
  # Params:
  # +country+:: Required parameter (can't be nil and must be valid)
  # +location+:: Optional parameter (must be valid)
  # +page_number+:: Optional parameter (must be valid)
  # +keywords+:: Optional parameter (format [keyword, initial_page_number])
  def self.scrape_data(country= 'USA', location= 'Delhi',  page_number= 1, keywords= [['twitter',1], ['google',1], ['netflix',1], ['bollywood',1]])
    new.scrape_data(country, location, page_number, keywords)
  end

  # Scrape jobs from indeed
  # Params:
  # +country+:: Required parameter (can't be nil and must be valid)
  # +location+:: Optional parameter (must be valid)
  # +page_number+:: Optional parameter (must be valid)
  # +keywords+:: Optional parameter (format [keyword, initial_page_number])
  def scrape_data(country= 'USA', location= 'Delhi', page_number= 1, keywords= [['twitter',1], ['google',1], ['netflix',1], ['bollywood',1]])
    scraper = Scraper.where(name: 'indeed_scraper').first_or_create
    @scraper_log = scraper.scraper_logs.create(status: 0, records_found: 0, start_time: DateTime.now)

    field_names = [:job_title, :company, :location, :country, :reviews_count, :apply_link, :description]

    keywords.each do |keyword|
      puts "🌇   #{keyword}    🌇"

      page_number = keyword[1] || 1
      page_number = page_number.to_i
      location = CGI.escape location||""
      keyword = CGI.escape keyword[0]
      # Keyword which we are currently processing (In case of failure easier to restart scraper)
      @scraper_log.update_attributes(keyword: keyword)

      base_url = base_url_for country
      relative_url = relative_url_for(location, page_number, keyword)

      while page_number
        @scraper_log.update_attributes(page_number: page_number)

        page_url = base_url + relative_url
        puts "📣         Page URL: #{page_url}       📣"
        begin
          page = get_page(page_url)
          next unless page
          body = parse_body(page.body)

          ############### Individual jobs cards ###############
          cards = body.search('.jobsearch-SerpJobCard')
          puts "✅  #{cards.count}"

          next unless cards

          mutex = Mutex.new

          # New thread for each card
          threads = cards.map do |card|
            Thread.new do
              scraped_data = {}
              field_names.each do |field_name|
                scraped_data[field_name] = ""
              end
              job_title_anchor = card.xpath(".//h2[@class='jobtitle']/a")[0] || card.xpath(".//a[contains(concat(' ', normalize-space(@class), ' '), ' jobtitle ')]")[0]
              job_link = job_title_anchor.xpath("./@href")[0].value.strip
              pp (base_url + job_link)

              scraped_data[:job_title] = job_title_anchor.xpath("./@title")[0].value.strip
              company = card.xpath(".//div[@class='companyInfoWrapper']/div/span[@class='company']/a/text()")[0] || card.xpath(".//a[@data-tn-element='companyName']/text()")[0]
              company = card.xpath(".//div[@class='companyInfoWrapper']/div/span[@class='company']/span/text()")[0] if (!company || company.text.strip.empty?)
              company = card.xpath(".//div[@class='companyInfoWrapper']/div/span[@class='company']/node()") if (!company || company.text.strip.empty?)
              scraped_data[:company] = company.text.strip if company
              scraped_data[:location] = (card.search('.location')).text.strip
              scraped_data[:country] = country
              reviews = card.xpath(".//div[@class='companyInfoWrapper']/div/a/span[2]/text()")[0] || card.xpath(".//a[@data-tn-element='reviewStars']/span[2]/text()")[0]
              scraped_data[:reviews_count] = reviews.text.strip if reviews
              scraped_data[:reviews_count] = scraped_data[:reviews_count].to_i

              begin
                details_page = get_page(base_url + job_link)
                next unless details_page
                details_body = parse_body(details_page.body)

                apply_link = details_body.xpath("//div[@id='viewJobButtonLinkContainer']//a/@href")[0] || details_body.xpath("//div[@id='viewJobButtonLinkContainer']//a/@href")[1]
                scraped_data[:apply_link] = apply_link.value.strip if apply_link
                scraped_data[:apply_link] = (base_url + job_link) if scraped_data[:apply_link].strip.empty?
                company = details_body.xpath("//div[contains(concat(' ', normalize-space(@class), ' '), ' jobsearch-InlineCompanyRating ')]/div[1]/text()")[0]
                scraped_data[:company] = company.text.strip if scraped_data[:company].strip.empty? && company

                description = details_body.xpath("//div[contains(concat(' ', normalize-space(@class), ' '), ' jobsearch-JobComponent-description ')]/node()").text
                scraped_data[:description] = description.inspect
              rescue Net::OpenTimeout => e
                "⏰ Connection Timeout Skipping details page #{base_url + job_link} ⏰"
              end

              # Store data in database
              mutex.synchronize do
                Job.create(scraped_data)
                @scraper_log.reload
                @scraper_log.records_found += 1
                @scraper_log.save
              end

              # pp scraped_data.values
            end
          end

          # Waiting
          threads.each(&:join)

        rescue Net::OpenTimeout => e
          "❌ Connection Timeout Skipping ❌"
        end

        page_number+=1
        relative_url = relative_url_for(location, page_number, keyword)
        page_number = nil if body.xpath("//div[@class='pagination']/a[@href='#{relative_url}']").count == 0
      end
      ### -----Cities------  ####
    end

    @scraper_log.update_attributes(end_time: DateTime.now, status: 1)
  end

  ############### Private Methods ###############

  private

    def parse_body(body)
      Nokogiri::HTML(body.encode!('UTF-8', 'UTF-8', invalid: :replace, undef: :replace, replace: ''))
    end

    def get_page(page_link)
      begin
        all_response_code = ['403', '404', '502']
        proxies = ['23.81.92.2', '172.241.186.114', '23.82.105.53', '172.241.187.104', '23.82.105.250', '172.241.186.173', '23.82.109.224', '23.81.92.49', '23.81.69.93', '172.241.187.4', '23.80.154.144', '23.82.105.58', '23.80.155.209', '23.81.69.134', '23.82.109.48', '23.81.92.227', '172.241.187.20', '136.0.118.32']
        Mechanize.start do |mechanize|
          mechanize.request_headers = { "Accept-Encoding" => "gzip, deflate, br", "authority" => "www.indeed.com.pk", "scheme" => "https", "accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" }
          mechanize.user_agent = UserAgent.random
          proxy = proxies.sample
          mechanize.set_proxy proxy, 29842, 'anicol', '3wP74ZkY'
          page = mechanize.get(page_link)
        end
      rescue Mechanize::ResponseCodeError => e
        if all_response_code.include? e.response_code
          puts e
          puts "Better luck next year!"
        end
      rescue => e
        puts "❌  Something went wrong, but no stopping......   ❌ "
        puts e
      end
    end

    def base_url_for(country)
      case country.downcase
      when 'india'
        "https://www.indeed.co.in"
      when 'germany'
        "https://de.indeed.com"
      when 'usa'
        "https://www.indeed.com"
      end
    end

    def relative_url_for(location, page_number, keyword)
      path = "/jobs?q=#{keyword}&l=#{location}&start=#{(page_number-1)*10}"
      path.remove('&l=') unless location.present?
    end

end