# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_04_02_120810) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "jobs", force: :cascade do |t|
    t.string "job_title"
    t.string "company"
    t.string "location"
    t.string "country"
    t.integer "reviews_count"
    t.string "apply_link"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scraper_logs", force: :cascade do |t|
    t.integer "status"
    t.integer "records_found"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "scraper_id"
    t.integer "pid"
    t.integer "conn_tried"
    t.integer "conn_failed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "page_number"
    t.index ["scraper_id"], name: "index_scraper_logs_on_scraper_id"
  end

  create_table "scrapers", force: :cascade do |t|
    t.integer "thread_size", default: 1
    t.boolean "proxy_usage", default: true
    t.string "http_method", default: "get"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
  end

end
