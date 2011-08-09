class FundDepositRequest < ActiveRecord::Base

  belongs_to :user
  belongs_to :bankaccount

  validates_presence_of :bankaccount, :amount_requested, :amount_received, :currency
  validates_numericality_of :amount_requested, :greater_than => 0.0, :unless => :created_by_admin?
  validates_numericality_of :amount_received, :greater_than => 0.0, :on => :update

  module  Status
    PENDING = :pending
    COMPLETE = :complete
    CANCELLED = :cancelled
  end

end
