class Fund < ActiveRecord::Base
  belongs_to :user
  has_many :fund_transaction_details
  
  module Type
    BTC = 'BTC'
    USD = 'USD'
  end
  
  def debit vals
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
                              :btc_withdraw_request_id => vals[:btc_withdraw_request_id]
  end
  def self.update_seller_btc_fund_on_execution(ask)
    ask_btc_fund = Fund.find_btc(ask.user_id)
    ask_btc_fund.update_attributes(:amount => (ask_btc_fund.amount - ask.amount),
                                :reserved => (ask_btc_fund.reserved - ask.amount))
  end
  def self.update_buyer_usd_fund_on_execution(bid)
    bid_usd_fund = Fund.find_usd(bid.user_id)
    total_bid_amount = bid.amount * bid.price
    bid_usd_fund.update_attributes(:amount => (bid_usd_fund.amount - total_bid_amount),
                                :reserved => (bid_usd_fund.reserved - total_bid_amount))
  end
  def update_seller_usd_fund_on_execution(order)
    ask_total_income = order.amount * order.price
    self.update_attributes(:amount => (self.amount + ask_total_income),
                          :available => (self.available + ask_total_income))
  end
  def update_buyer_btc_fund_on_execution(order)
    self.update_attributes(:amount => (self.amount + order.amount),
                          :available => (self.available + order.amount))
  end
  def self.find_btc(user_id)
    Fund.first(:conditions => {:user_id => user_id, :fund_type => Fund::Type::BTC})
  end
  def self.find_usd(user_id)
    Fund.first(:conditions => {:user_id => user_id, :fund_type => Fund::Type::USD})
  end
  def self.update_buyer_usd_fund_on_cancel(bid)
    total_bid_amount = bid.amount_remaining * bid.price
    usd_fund = Fund.find_usd(bid.user_id)
    usd_fund.update_attributes(:available => (usd_fund.available + total_bid_amount),
                              :reserved => (usd_fund.reserved - total_bid_amount))
  end
  def self.update_seller_btc_fund_on_cancel(ask)
    btc_fund = Fund.find_btc(ask.user_id)
    btc_fund.update_attributes(:available => (btc_fund.available + ask.amount), 
                              :reserved => (btc_fund.reserved - ask.amount))
  end
  def to_json(*args)
    {:amount => amount.to_f, :available => available.to_f, :reserved => reserved.to_f}.to_json(args)
  end
end
