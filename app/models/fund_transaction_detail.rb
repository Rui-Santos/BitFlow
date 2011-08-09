class FundTransactionDetail < ActiveRecord::Base
	belongs_to :user
	belongs_to :fund
	belongs_to :btc_withdraw_request
	belongs_to :trade

	module Status
    PENDING = :pending
    COMMITTED = :committed
    ROLLED_BACK = :rolled_back
  end
  
  module TransactionType
    DEBIT = :debit
    CREDIT = :credit
  end
  
  module TransactionCode
    PAYMENT_RECEIVED = :payment_received
    PAYMENT_SENT = :payment_sent
    BITCOIN_SOLD = :bitcoin_sold
    BITCOIN_PURCHASED = :bitcoin_purchased
    COMMISSION = :commission
    WITHDRAWAL = :withdrawal
    WITHDRAWAL_FEE = :withdrawal_fee
    DEPOSIT_FEE = :deposit_fee
    BITCOIN_FEE = :bitcoin_fee    
  end
  
end
