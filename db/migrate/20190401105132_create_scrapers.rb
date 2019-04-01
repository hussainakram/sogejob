class CreateScrapers < ActiveRecord::Migration[5.2]
  def change
    create_table :scrapers do |t|
      t.integer :thread_size, default: 1
      t.boolean :proxy_usage, default: true
      t.string :http_method, default: "get"

      t.timestamps
    end
  end
end
