class Bid < Order
  set_table_name :bids
  has_many :trades
  
  def self.order_queue(value)
    active.greater_price_than(value).oldest
  end

  def match!
    Ask.order_queue(self.price)
  end
  
  def to_json(*args)
    super(*args).merge(:type => 'ask')
  end
  
end
