class Bid < Order
  set_table_name :bids

  has_many :trades

  before_create :adjust_funds

  def after_initialize
    self.status = Order::Status::ACTIVE
  end
  
  def self.order_queue(value)
    active.greater_price_than(value).oldest
  end

  def match!
    Ask.order_queue(self.price)
  end
  
  def adjust_funds
    self.amount_remaining = self.amount.to_f
    usd_fund = Fund.find_usd(self.user_id)
    total_bid_amount = self.amount * self.price
    commission = self.user.commission
    if (total_bid_amount + commission) <= usd_fund.available
      usd_fund.update_attributes(:amount => (usd_fund.amount - commission),
                                  :available => (usd_fund.available - total_bid_amount - commission),
                                  :reserved => (usd_fund.reserved + total_bid_amount))
    else
      self.errors.add(:base, "Not enough USD fund available")
      return false
    end
  end

  def create_trades
    return if AppConfig.is?('SKIP_TRADE_CREATION', false)

    bid = self.reload
    
    buyer_usd_fund = Fund.find_usd(bid.user_id)
    buyer_btc_fund = Fund.find_btc(bid.user_id)
    
    bid_amount_remaining = bid.amount_remaining
    
    bid.match!.each do |ask|
      break if bid_amount_remaining == 0
      
      traded_price = 0.0;
      traded_amount = 0.0;
      
      if bid_amount_remaining >= ask.amount_remaining
        traded_price = ask.price
        traded_amount = ask.amount_remaining
      else
        traded_price = ask.price
        traded_amount = bid_amount_remaining
      end
      
      Trade.create(ask: ask, bid: bid, market_price: traded_price, amount: traded_amount)
      
      buyer_usd_fund_amount = buyer_usd_fund.amount - traded_price * traded_amount
      buyer_usd_fund_reserved = buyer_usd_fund.reserved - bid.price * traded_amount
      buyer_usd_fund.update_attributes(:amount => buyer_usd_fund_amount,
                                      :reserved => buyer_usd_fund_reserved,
                                      :available => (buyer_usd_fund_amount - buyer_usd_fund_reserved))
      buyer_btc_fund.update_attributes(:amount => (buyer_btc_fund.amount + traded_amount),
                                      :available => (buyer_btc_fund.available + traded_amount))
      
      seller_usd_fund = Fund.find_usd(ask.user_id)
      seller_btc_fund = Fund.find_btc(ask.user_id)
      
      seller_usd_fund.update_attributes(:amount => (seller_usd_fund.amount + traded_price * traded_amount),
                                      :available => (seller_usd_fund.available + traded_price * traded_amount))
      seller_btc_fund.update_attributes(:amount => (seller_btc_fund.amount - traded_amount),
                                      :reserved => (seller_btc_fund.reserved - traded_amount))
      
      bid_amount_remaining = bid_amount_remaining - traded_amount
      ask_amount_remaining = ask.amount_remaining - traded_amount
      if ask_amount_remaining == 0
        ask.update_attributes(:amount_remaining => ask_amount_remaining, :status => Order::Status::COMPLETE)
      else
        ask.update_attribute(:amount_remaining, ask_amount_remaining)
      end
    end
    bid.amount_remaining = bid_amount_remaining
    bid.status = Order::Status::COMPLETE if bid.amount_remaining == 0
    bid.save
  end
  
  def to_json(*args)
    super(*args).merge(:type => 'ask')
  end
  
end
