class BtcWithdrawRequest < ActiveRecord::Base
	belongs_to :user

	validates_presence_of :destination_btc_address, :amount, :message
  validates_numericality_of :amount, :greater_than => 0.0

  module Status
    PENDING = :pending
    COMPLETE = :complete
  end

end
