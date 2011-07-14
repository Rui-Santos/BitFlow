class Bid < Order
  set_table_name :bids
  
  def match!
    Ask.order_queue(self.price)
  end
  
  def self.lesser_price(price)
    where("bids.price <= ?", price).order("bids.price DESC")
  end
end
