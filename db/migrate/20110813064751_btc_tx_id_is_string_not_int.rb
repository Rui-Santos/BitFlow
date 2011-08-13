class BtcTxIdIsStringNotInt < ActiveRecord::Migration
  def self.up
    remove_column :btc_withdraw_requests, :btc_tx_id
    add_column :btc_withdraw_requests, :btc_tx_id, :string
  end

  def self.down
    remove_column :btc_withdraw_requests, :btc_tx_id
    add_column :btc_withdraw_requests, :btc_tx_id, :integer
  end
end
