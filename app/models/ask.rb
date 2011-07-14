class Ask < Order
  set_table_name :asks

  def self.order_queue(value)
    active.oldest.lesser_price_than(value)
  end

  def match!
    Bid.order_queue(self.price)
  end

end
