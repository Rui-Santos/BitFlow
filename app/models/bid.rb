class Bid < Order
  set_table_name :bids
  belongs_to :trade
  def self.order_queue(value)
    active.oldest.greater_price_than(value)
  end
  
  def match!
    Ask.order_queue(self.price)
  end
  
  def create_trades
    return if  AppConfig.is?('SKIP_TRADE_CREATION', false)
    pending_amount = self.amount
    asks = []
    match!.each do | ask|
      break if pending_amount == 0
      pending_amount -= ask.amount
      asks << ask
    end
    unless(asks.empty?)
      self.update_attributes(:status => Order::Status::COMPLETE)
      asks.each{|a| a.update_attributes(:status => Order::Status::COMPLETE)}
      Trade.create(:asks => asks, :bids => [self])
    end
  end
end
