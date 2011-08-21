class Ask < Order
  set_table_name :asks
  has_many :trades
  validate :account_balances
  
  
  def account_balances
    btc_fund = user.btc
    if (amount|| 0.0) > btc_fund.available
      errors.add(:base, "Not enough Bitcoin fund available")
      return false
    end
    usd_fund = user.usd
    if user.commission > usd_fund.available
      errors.add(:base, "Not enough USD fund available")
      return false
    end
  end

  def match
    market? ? Bid.market_order_queue : Bid.order_queue(self.price)
  end

  def self.order_queue(value)
    active.lesser_price_than(value).oldest
  end
  
  def self.market_order_queue
    active.lowest.oldest
  end

  def to_json(*args)
    super(*args).merge(:type => 'ask')
  end
end
