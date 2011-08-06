class Ask < Order
  set_table_name :asks
  has_many :trades

  def self.order_queue(value)
    active.lesser_price_than(value).oldest
  end

  def match!
    Bid.order_queue(self.price)
  end
  
  def to_json(*args)
    super(*args).merge(:type => 'ask')
  end
end
