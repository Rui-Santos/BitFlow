class Fund < ActiveRecord::Base
  belongs_to :user
  has_many :fund_transaction_details
  
  module Type
    BTC = 'BTC'
    USD = 'USD'
  end
  
  def debit!(vals)
    transact(vals.merge(:fund_id => self.id, :tx_type => FundTransactionDetail::TransactionType::DEBIT))
  end
  
  def credit!(vals)
    transact(vals.merge(:fund_id => self.id, :tx_type => FundTransactionDetail::TransactionType::CREDIT))
  end
  
  def reserve!(reserve_amount)
    update_attributes(:reserved => (reserved + reserve_amount),:available => (amount - (reserved + reserve_amount)))
  end
  
  def unreserve!(reserve_amount)
    update_attributes(:reserved => (reserved - reserve_amount),
                      :available => (amount - (reserved - reserve_amount)))
  end
  def to_json(*args)
    {:amount => amount.to_f, :available => available.to_f, :reserved => reserved.to_f}.to_json(args)
  end
  
  private

  def transact(vals)
    update_attributes(:amount => (amount - vals[:amount]), :available => (amount - vals[:amount] - reserved))
    FundTransactionDetail.create(vals)
  end
  
end
