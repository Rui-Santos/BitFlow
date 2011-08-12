class TruncateAllDataButUser < ActiveRecord::Migration
  def self.up
    # Ask.all.each {|x| x.destroy}
    #     Bankaccount.all.each {|x| x.destroy}
    #     Bid.all.each {|x| x.destroy}
    #     BtcWithdrawRequest.all.each {|x| x.destroy}
    #     FundDepositRequest.all.each {|x| x.destroy}
    #     FundTransactionDetail.all.each {|x| x.destroy}
    #     FundWithdrawRequest.all.each {|x| x.destroy}
    #     Fund.all.each {|x| x.update_attributes :amount=>0.0,:reserved=>0.0,:available=>0.0}
    #     Trade.all.each {|x| x.destroy}
    UserWallet.all.each {|wallet| wallet.update_attribute :last_received_epoch, 0}
    
    add_index :asks, :status
    add_index :asks, :user_id
    
    add_index :bankaccounts, :status
    add_index :bankaccounts, :user_id
    add_index :bankaccounts, :number
    
    add_index :bids, :status
    add_index :bids, :user_id
    
    add_index :btc_withdraw_requests, :user_id
    add_index :btc_withdraw_requests, :status
    
    add_index :fund_deposit_requests, :status
    add_index :fund_deposit_requests, :user_id
    
    add_index :fund_transaction_details, :status
    add_index :fund_transaction_details, :user_id
    add_index :fund_transaction_details, :currency
    
    add_index :fund_withdraw_requests, :status
    add_index :fund_withdraw_requests, :user_id    
    
    add_index :funds, :user_id
    add_index :funds, :fund_type
    
    add_index :trades, :status
    add_index :trades, :ask_id
    add_index :trades, :bid_id

    add_index :user_wallets, :status
    add_index :user_wallets, :user_id
    add_index :user_wallets, :name    
    
  end

  def self.down
  end
end
