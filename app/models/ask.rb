class Ask < Order
  set_table_name :asks
  has_many :trades

  before_create :adjust_funds

  def adjust_funds
    ask = self
    ask.amount_remaining = ask.amount
    btc_fund = Fund.find_btc(ask.user_id)
    usd_fund = Fund.find_usd(ask.user_id)
    commission = Commission.amount(ask.user_id)
    if ask.amount <= btc_fund.available
      if commission <= usd_fund.available
        btc_fund.update_attributes(:available => (btc_fund.available - ask.amount), 
                                  :reserved => (btc_fund.reserved + ask.amount))
        usd_fund.update_attributes(:amount => (usd_fund.amount - commission), 
                                    :available => (usd_fund.available - commission))
      else
        ask.errors.add(:base, "Not enough USD fund available")
        return false
      end
    else
      ask.errors.add(:base, "Not enough Bitcoin fund available")
      return false
    end
  end
  
  def self.order_queue(value)
    active.lesser_price_than(value).oldest
  end

  def match!
    Bid.order_queue(self.price)
  end
  
  def create_trades
    return if  AppConfig.is?('SKIP_TRADE_CREATION', false)
    
    ask = self.reload
    
    seller_usd_fund = Fund.find_usd(ask.user_id)
    seller_btc_fund = Fund.find_btc(ask.user_id)
    
    ask_amount_remaining = ask.amount_remaining
    
    ask.match!.each do |bid|
      break if ask_amount_remaining == 0
      
      traded_price = 0.0;
      traded_amount = 0.0;
      
      if ask_amount_remaining >= bid.amount_remaining
        traded_price = ask.price
        traded_amount = bid.amount_remaining
      else
        traded_price = ask.price
        traded_amount = ask_amount_remaining
      end
      
      Trade.create(ask: ask, bid: bid, market_price: traded_price, amount: traded_amount)
      
      buyer_usd_fund = Fund.find_usd(bid.user_id)
      buyer_btc_fund = Fund.find_btc(bid.user_id)
      buyer_usd_fund_amount = buyer_usd_fund.amount - traded_price * traded_amount
      buyer_usd_fund_reserved = buyer_usd_fund.reserved - bid.price * traded_amount
      buyer_usd_fund.update_attributes(:amount => buyer_usd_fund_amount,
                                      :reserved => buyer_usd_fund_reserved,
                                      :available => (buyer_usd_fund_amount - buyer_usd_fund_reserved))
      buyer_btc_fund.update_attributes(:amount => (buyer_btc_fund.amount + traded_amount),
                                      :available => (buyer_btc_fund.available + traded_amount))
      
      seller_usd_fund.update_attributes(:amount => (seller_usd_fund.amount + traded_price * traded_amount),
                                      :available => (seller_usd_fund.available + traded_price * traded_amount))
      seller_btc_fund.update_attributes(:amount => (seller_btc_fund.amount - traded_amount),
                                      :reserved => (seller_btc_fund.reserved - traded_amount))
      
      ask_amount_remaining = ask_amount_remaining - traded_amount
      bid_amount_remaining = bid.amount_remaining - traded_amount
      if bid_amount_remaining == 0
        bid.update_attributes(:amount_remaining => bid_amount_remaining, :status => Order::Status::COMPLETE)
      else
        bid.update_attribute(:amount_remaining, bid_amount_remaining)
      end
    end
    ask.amount_remaining = ask_amount_remaining
    ask.status = Order::Status::COMPLETE if ask.amount_remaining == 0
    ask.save
  end
end
