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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110805200432) do

  create_table "asks", :force => true do |t|
    t.decimal  "price",            :precision => 15, :scale => 10
    t.decimal  "amount",           :precision => 15, :scale => 10
    t.string   "currency"
    t.string   "status",                                                            :null => false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "amount_remaining", :precision => 15, :scale => 10, :default => 0.0
  end

  create_table "bankaccounts", :force => true do |t|
    t.string   "name"
    t.string   "number"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
  end

  create_table "bids", :force => true do |t|
    t.decimal  "price",            :precision => 15, :scale => 10
    t.decimal  "amount",           :precision => 15, :scale => 10
    t.string   "currency"
    t.string   "status",                                                            :null => false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "amount_remaining", :precision => 15, :scale => 10, :default => 0.0
  end

  create_table "btc_withdraw_requests", :force => true do |t|
    t.string   "destination_btc_address"
    t.decimal  "amount",                  :precision => 15, :scale => 10
    t.integer  "user_id"
    t.string   "message"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "btc_tx_id"
  end

  create_table "fund_deposit_requests", :force => true do |t|
    t.decimal  "amount",         :precision => 15, :scale => 10
    t.integer  "bankaccount_id"
    t.integer  "user_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "currency"
    t.decimal  "net_amount",     :precision => 15, :scale => 10
    t.string   "deposit_code"
  end

  create_table "fund_transaction_details", :force => true do |t|
    t.decimal  "amount",                  :precision => 15, :scale => 10
    t.string   "tx_type"
    t.integer  "user_id"
    t.integer  "fund_id"
    t.string   "tx_code"
    t.string   "currency"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.string   "message"
    t.integer  "trade_id"
    t.integer  "btc_withdraw_request_id"
    t.integer  "fund_deposit_request_id"
  end

  create_table "funds", :force => true do |t|
    t.string   "fund_type"
    t.decimal  "amount",     :precision => 15, :scale => 10, :default => 0.0
    t.decimal  "reserved",   :precision => 15, :scale => 10, :default => 0.0
    t.decimal  "available",  :precision => 15, :scale => 10, :default => 0.0
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hosts", :force => true do |t|
    t.string   "ip_address", :null => false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "settings", :force => true do |t|
    t.string   "data",                       :null => false
    t.integer  "user_id"
    t.string   "setting_type", :limit => 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["setting_type", "user_id"], :name => "index_settings_on_setting_type_and_user_id"

  create_table "trades", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "market_price", :precision => 15, :scale => 10
    t.decimal  "amount",       :precision => 15, :scale => 10, :default => 0.0
    t.integer  "ask_id"
    t.integer  "bid_id"
    t.string   "status"
  end

  create_table "user_wallets", :force => true do |t|
    t.string   "name"
    t.string   "status"
    t.string   "address"
    t.decimal  "balance",    :precision => 15, :scale => 10
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "",    :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "failed_attempts",                       :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                                 :default => false
    t.string   "name"
    t.string   "referral_code"
    t.integer  "referrer_fund_id"
    t.string   "token"
    t.string   "secret"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

end
