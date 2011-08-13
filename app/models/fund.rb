class Fund < ActiveRecord::Base
  belongs_to :user
  has_many :fund_transaction_details
  
  module Type
    BTC = 'BTC'
    USD = 'USD'
  end
  
  def debit!(vals)
    vals = vals.merge(:fund_id => self.id, :tx_type => FundTransactionDetail::TransactionType::DEBIT)
    update_attributes(:amount => (amount - vals[:amount]), :available => (amount - vals[:amount] - reserved))
    FundTransactionDetail.create(vals)
  end
  
  def credit!(vals)
    vals = vals.merge(:fund_id => self.id, :tx_type => FundTransactionDetail::TransactionType::CREDIT)
    update_attributes(:amount => (amount + vals[:amount]), :available => (amount + vals[:amount] - reserved))
    FundTransactionDetail.create(vals)
  end
  
  def reserve!(reserve_amount)
    update_attributes(:reserved => (reserved + reserve_amount),:available => (amount - (reserved + reserve_amount)))
    Rails.logger.info "Fund#{id} Type #{fund_type} reserved #{reserve_amount}"
  end
  
  def unreserve!(reserve_amount)
    update_attributes(:reserved => (reserved - reserve_amount),:available => (amount - (reserved - reserve_amount)))
    Rails.logger.info "Fund#{id} Type #{fund_type} UNreserved #{reserve_amount}"
  end
  
  def to_json(*args)
    {:amount => amount.to_f, :available => available.to_f, :reserved => reserved.to_f}.to_json(args)
  end
  
end
