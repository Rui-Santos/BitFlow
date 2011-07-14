class Ask < Order
  set_table_name :asks
  

  def self.greater_price(price)
    where("asks.price >= ?", price).order("asks.price DESC")
  end

  
  def self.order_queue(value)
    Ask.active
  end
end
