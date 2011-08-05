class FundDepositRequest < ActiveRecord::Base

  belongs_to :user
  belongs_to :bankaccount

  validates_presence_of :bankaccount, :amount, :currency
  validates_numericality_of :amount, :greater_than => 0.0

  module  Status
    PENDING = :pending
    COMPLETE = :complete
    CANCELLED = :cancelled
  end

end
