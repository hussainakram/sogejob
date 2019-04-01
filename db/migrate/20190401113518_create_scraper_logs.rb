class CreateScraperLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :scraper_logs do |t|
      t.integer :status
      t.integer :records_found
      t.datetime :start_time
      t.datetime :end_time
      t.integer :scraper_id
      t.integer :pid
      t.integer :conn_tried
      t.integer :conn_failed

      t.timestamps
    end
    add_index :scraper_logs, :scraper_id
  end
end
