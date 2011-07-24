class Ask < Order
  set_table_name :asks
  belongs_to :trade
  
  before_create do |ask|
    btc_fund = Fund.find_btc(ask.user_id)
    usd_fund = Fund.find_usd(ask.user_id)
    if ask.amount <= btc_fund.available
      if Commission::AMOUNT <= usd_fund.available
        btc_fund.update_attributes(:available => (btc_fund.available - ask.amount), 
                                  :reserved => (btc_fund.reserved + ask.amount))
        usd_fund.update_attributes(:amount => (usd_fund.amount - Commission::AMOUNT), 
                                    :available => (usd_fund.available - Commission::AMOUNT))
      else
        ask.errors.add(:base, "Not enough USD fund available")
        return false
      end
    else
      ask.errors.add(:base, "Not enough Bitcoin fund available")
      return false
    end
  end
  
  before_destroy do |ask|
    Fund.update_seller_btc_fund_on_cancel ask
  end
  
  def self.order_queue(value)
    active.lesser_price_than(value).oldest
  end

  def match!
    Bid.order_queue(self.price)
  end
  
  def create_trades
    return if  AppConfig.is?('SKIP_TRADE_CREATION', false)
    pending_amount = self.amount
    bids = []
    match!.each do | bid|
      break if pending_amount == 0
      pending_amount -= bid.amount
      bids << bid
    end
    unless(bids.empty?)
      self.update_attributes(:status => Order::Status::COMPLETE)
      Fund.update_seller_btc_fund_on_execution self
      seller_usd_fund = Fund.find_usd(self.user_id)
      bids.each do |b| 
        b.update_attributes(:status => Order::Status::COMPLETE)
        seller_usd_fund.update_seller_usd_fund_on_execution b
        Fund.update_buyer_usd_fund_on_execution b
        Fund.find_btc(b.user_id).update_buyer_btc_fund_on_execution b
      end
      Trade.create(asks: [self], bids: bids, market_price: self.price)
    end
  end
end
