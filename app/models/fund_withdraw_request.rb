class FundWithdrawRequest < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :bankaccount  
  
  validates_presence_of :bankaccount_id, :amount, :currency
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
