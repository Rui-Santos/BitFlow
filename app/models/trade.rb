class Trade < ActiveRecord::Base
  belongs_to :ask
  belongs_to :bid

  scope :user_transactions, lambda { |user|
    joins([:bids, :asks]).where('bids.user_id = ? and asks.user_id = ?', user.id, user.id).order(:updated_at).reverse_order
  }

  # def amount
  #   bid.amount
  # end

  def sold
    ask.amount.round(2)
  end

  def bought
    bid.amount.round(2)
  end
  
  module Status
    CREATED = :created
    PENDING = :pending
    COMPLETE = :complete
  end
  
end
