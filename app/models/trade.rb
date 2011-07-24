class Trade < ActiveRecord::Base
  has_many :asks
  has_many :bids

  scope :user_transactions, lambda { |user|
    joins([:bids, :asks]).where('bids.user_id = ? and asks.user_id = ?', user.id, user.id).order(:updated_at).reverse_order
  }

  def amount
    bids.inject(0){|sum, b| sum += b.amount}
  end
  
  def sold
    asks.collect(&:amount).reduce(&:+).round(2)
  end

  def bought
    bids.collect(&:amount).reduce(&:+).round(2)
  end
end
