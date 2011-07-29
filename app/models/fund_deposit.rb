class FundDeposit < ActiveRecord::Base

  belongs_to :user
  belongs_to :bankaccount

  validates_presence_of :bankaccount, :amount, :currency

  module  Status
    PENDING = :pending
    COMPLETE = :complete
    CANCELLED = :cancelled
  end

end
