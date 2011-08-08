class FundDepositFeeAllCol < ActiveRecord::Migration
  def self.up
    rename_column :fund_deposit_requests, :net_amount, :amount_received
    rename_column :fund_deposit_requests, :amount, :amount_requested
    add_column :fund_deposit_requests, :fee, :decimal, :precision => 15, :scale => 10
  end

  def self.down
    remove_column :fund_deposit_requests, :fee
    rename_column :fund_deposit_requests, :amount_received, :net_amount
    rename_column :fund_deposit_requests, :amount_requested, :amount
  end
end
