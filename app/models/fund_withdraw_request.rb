class FundWithdrawRequest < ActiveRecord::Base
  
  belongs_to :user
  
  validates_presence_of :beneficiary_name, :beneficiary_address, :amount, :currency
  validates_numericality_of :amount, :greater_than => 0.0
  
  
  module  Status
    PENDING = :pending
    SUCCESS = :success
    DECLINED = :declined
  end
  
  def decision
    @action
  end
  
  def decision=(a)
    @decision = a
  end
end
