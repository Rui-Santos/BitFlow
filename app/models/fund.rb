class Fund < ActiveRecord::Base
  belongs_to :user
  has_many :fund_transaction_details
  
  module Type
    BTC = 'BTC'
    USD = 'USD'
  end
  
  def debit! vals
    update_attributes(:amount => (amount - vals[:amount]),
                      :available => (amount - vals[:amount] - reserved))
    FundTransactionDetail.create :amount => vals[:amount],
                              :tx_type => FundTransactionDetail::TransactionType::DEBIT,
                              :tx_code => vals[:tx_code],
                              :currency => vals[:currency],
                              :status => vals[:status],
                              :message => vals[:message],
                              :user_id => vals[:user_id],
                              :fund_id => self.id,
                              :btc_withdraw_request_id => vals[:btc_withdraw_request_id],
                              :trade_id => vals[:trade_id],
                              :ask_id => vals[:ask_id],
                              :bid_id => vals[:bid_id],
                              :fund_withdraw_request_id => vals[:fund_withdraw_request_id]
  end
  def credit! vals
    update_attributes(:amount => (amount + vals[:amount]),
                      :available => (amount + vals[:amount] - reserved))
    FundTransactionDetail.create :amount => vals[:amount],
                              :tx_type => FundTransactionDetail::TransactionType::CREDIT,
                              :tx_code => vals[:tx_code],
                              :currency => vals[:currency],
                              :status => vals[:status],
                              :message => vals[:message],
                              :user_id => vals[:user_id],
                              :fund_id => self.id,
                              :btc_withdraw_request_id => vals[:btc_withdraw_request_id],
                              :fund_deposit_request_id => vals[:fund_deposit_request_id],
                              :trade_id => vals[:trade_id],
                              :ask_id => vals[:ask_id],
                              :bid_id => vals[:bid_id],
                              :fund_withdraw_request_id => vals[:fund_withdraw_request_id]
  end
  def reserve! reserve_amount
    update_attributes(:reserved => (reserved + reserve_amount),
                      :available => (amount - (reserved + reserve_amount)))
  end
  def unreserve! reserve_amount
    update_attributes(:reserved => (reserved - reserve_amount),
                      :available => (amount - (reserved - reserve_amount)))
  end
  def to_json(*args)
    {:amount => amount.to_f, :available => available.to_f, :reserved => reserved.to_f}.to_json(args)
  end
end
