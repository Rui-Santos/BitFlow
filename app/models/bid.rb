class Bid < Order
  set_table_name :bids
  has_many :trades
  validate :balance
  def balance
    usd_fund = user.usd
    total_bid_amount = (amount || 0.0) * (order_price || 0.0)
    commission = user.commission
    if (total_bid_amount + commission) > usd_fund.available
      errors.add(:base, "Not enough USD fund available")
      return false
    end
    
  end

  def match
    Ask.order_queue(self.price)
  end
  
  def self.order_queue(value)
    active.greater_price_than(value).oldest
  end
  
  def to_json(*args)
    super(*args).merge(:type => 'ask')
  end
  
  def order_price
    limit? ? price : Trade.latest_market_price
  end
end
