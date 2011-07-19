class Trade < ActiveRecord::Base
  has_many :asks
  has_many :bids

  def amount
    bids.inject(0){|sum, b| sum += b.amount}
  end
end
