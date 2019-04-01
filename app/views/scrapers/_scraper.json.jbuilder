json.extract! scraper, :id, :thread_size, :proxy_usage, :http_method, :created_at, :updated_at
json.url scraper_url(scraper, format: :json)
