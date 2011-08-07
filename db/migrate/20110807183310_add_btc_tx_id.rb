class AddBtcTxId < ActiveRecord::Migration
  def self.up
    add_column :trades, :btc_tx_id, :string
  end

  def self.down
    remove_column :trades, :btc_tx_id
  end
end
