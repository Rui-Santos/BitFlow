class UserWallet < ActiveRecord::Base
	belongs_to :user

	module  Status
    ACTIVE = :active
    CANCELLED = :cancelled
  end
  
  def update_direct_receipts
    all_tx_details = BitcoinProxy.list_transactions(name, 100)
    all_tx_details.each do |tx_details|
      time = tx_details["time"].to_i
      if tx_details["category"] == 'receive' && 
          time > last_received_epoch && 
          tx_details["confirmations"].to_i > 5
        comment = tx_details["comment"]
        to = tx_details["to"]
        if (comment.nil? && to.nil?) || 
            (comment && !comment.start_with?("bf-withdraw") && !comment.start_with?("bf-trade") &&
            to && !to.start_with?("bf-withdraw") && !to.start_with?("bf-trade"))
          UserWallet.transaction do
            user.btc.credit! :amount => tx_details["amount"].to_f,
                              :tx_code => FundTransactionDetail::TransactionCode::PAYMENT_RECEIVED,
                              :currency => 'BTC',
                              :status => FundTransactionDetail::Status::COMMITTED,
                              :user_id => user.id
            update_attribute :last_received_epoch, time
          end
        end
      end
    end
  end
end
