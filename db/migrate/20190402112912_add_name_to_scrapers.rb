class AddNameToScrapers < ActiveRecord::Migration[5.2]
  def change
    add_column :scrapers, :name, :string
  end
end
