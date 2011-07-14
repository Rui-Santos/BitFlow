class Trade < ActiveRecord::Base
  has_many :asks
  has_many :bids
end
