# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20141214032700) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "orders", force: true do |t|
    t.string   "status"
    t.integer  "user_id"
    t.integer  "quad_arkopter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "job_id"
  end

  add_index "orders", ["quad_arkopter_id"], name: "index_orders_on_quad_arkopter_id", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "products", force: true do |t|
    t.integer  "stock_item_id"
    t.string   "inventory_name"
    t.string   "status"
    t.integer  "order_id"
    t.integer  "quad_arkopter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quad_arkopters", force: true do |t|
    t.string   "name"
    t.string   "status"
    t.integer  "deliveries",    default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "delivery_time", default: 60
  end

  create_table "stock_items", force: true do |t|
    t.string   "name"
    t.integer  "quantity"
    t.decimal  "price",      precision: 6, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
