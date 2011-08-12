class Bid < Order
  set_table_name :bids
  has_many :trades
  
  def to_json(*args)
    super(*args).merge(:type => 'ask')
  end
  
end
