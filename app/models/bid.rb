class Bid < Order
  set_table_name :bids
  after_create :match_bid
  def self.order_queue(value)
    active.oldest.greater_price_than(value)
  end
  
  def match!
    Ask.order_queue(self.price)
  end
  
  def match_bid
  end
end
