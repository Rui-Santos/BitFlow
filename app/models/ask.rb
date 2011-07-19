class Ask < Order
  set_table_name :asks
  belongs_to :trade
  
  def self.order_queue(value)
    active.oldest.lesser_price_than(value)
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
      bids.each{|b| b.update_attributes(:status => Order::Status::COMPLETE)}
      Trade.create(asks: [self], bids: bids, market_price: self.price)
    end
  end
end
