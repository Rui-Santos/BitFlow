class FeeColumnForBtcWithdrawal < ActiveRecord::Migration
  def self.up
    add_column :btc_withdraw_requests, :fee, :decimal, :precision => 15, :scale => 10
  end

  def self.down
    remove_column :btc_withdraw_requests, :fee
  end
end
