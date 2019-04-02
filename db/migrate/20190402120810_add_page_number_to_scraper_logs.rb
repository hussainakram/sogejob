class AddPageNumberToScraperLogs < ActiveRecord::Migration[5.2]
  def change
    add_column :scraper_logs, :page_number, :integer
  end
end
