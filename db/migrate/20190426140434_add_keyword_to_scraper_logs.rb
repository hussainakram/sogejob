class AddKeywordToScraperLogs < ActiveRecord::Migration[5.2]
  def change
    add_column :scraper_logs, :keyword, :string
  end
end
