class Bid < Order
  set_table_name :bids
  belongs_to :trade
  
  before_create do |bid|
    usd_fund = Fund.find_usd(bid.user_id)
    total_bid_amount = bid.amount * bid.price
    if (total_bid_amount + Commission::AMOUNT) <= usd_fund.available
      usd_fund.update_attributes(:amount => (usd_fund.amount - Commission::AMOUNT),
                                  :available => (usd_fund.available - total_bid_amount - Commission::AMOUNT),
                                  :reserved => (usd_fund.reserved + total_bid_amount))
    else
      bid.errors.add(:base, "Not enough USD fund available")
      return false
    end
  end
  
  before_destroy do |bid|
    Fund.update_buyer_usd_fund_on_cancel bid
  end

  def self.order_queue(value)
    active.greater_price_than(value).oldest
  end

  def match!
    Ask.order_queue(self.price)
  end

  def create_trades
    return if AppConfig.is?('SKIP_TRADE_CREATION', false)
    pending_amount = self.amount
    asks = []
    match!.each do | ask|
      break if pending_amount == 0
      pending_amount -= ask.amount
      asks << ask
    end
    unless(asks.empty?)
      self.update_attributes(status: Order::Status::COMPLETE)
      Fund.update_buyer_usd_fund_on_execution self
      buyer_btc_fund = Fund.find_btc(self.user_id)
      asks.each do |a|
        a.update_attributes(status: Order::Status::COMPLETE)
        buyer_btc_fund.update_buyer_btc_fund_on_execution a
        Fund.update_seller_btc_fund_on_execution a
        Fund.find_usd(a.user_id).update_seller_usd_fund_on_execution a
      end
      Trade.create(asks: asks, bids: [self], market_price: self.price)
    end
  end
end
