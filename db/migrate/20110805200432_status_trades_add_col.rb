class StatusTradesAddCol < ActiveRecord::Migration
  def self.up
    add_column :trades, :status, :string
    add_column :btc_withdraw_requests, :btc_tx_id, :integer
  end

  def self.down
    remove_column :trades, :status
    remove_column :btc_withdraw_requests, :btc_tx_id
  end
end
