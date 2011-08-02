class BtcFundTransfer < ActiveRecord::Base
	belongs_to :user
	belongs_to :fund

	validates_presence_of :destination_btc_address, :amount, :send_message
  validates_numericality_of :amount, :greater_than => 0.0

  module Status
    PENDING = :pending
    COMPLETE = :complete
  end

  module TransactionType
    CREDIT = :credit
    DEBIT = :debit
  end

  module Description
    PaymentReceived = :payment_received
    PaymentSent = :payment_sent
    BitcoinSold = :bitcoin_sold
    BitcoinPurchased = :bitcoin_purchased
  end
  
end
