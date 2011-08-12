class Bid < Order
  set_table_name :bids
  has_many :trades
  
  def to_json(*args)
    super(*args).merge(:type => 'ask')
  end
  
  def order_price
    limit? ? price : Trade.latest_market_price
  end
  
  def bid?
    true
  end
end
