class CreateJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :jobs do |t|
      t.string :job_title
      t.string :company
      t.string :location
      t.string :country
      t.integer :reviews_count
      t.string :apply_link
      t.text :description

      t.timestamps
    end
  end
end
