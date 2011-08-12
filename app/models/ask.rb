class Ask < Order
  set_table_name :asks
  has_many :trades


  def to_json(*args)
    super(*args).merge(:type => 'ask')
  end
  
  def bid?
    false
  end
end
