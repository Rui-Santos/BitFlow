module UserWalletsHelper
	def description fund_transaction_detail
		if fund_transaction_detail.tx_code.to_s == FundTransactionDetail::TransactionCode::PAYMENT_SENT.to_s
			'Payment Sent'
		elsif fund_transaction_detail.tx_code.to_s == FundTransactionDetail::TransactionCode::PAYMENT_RECEIVED.to_s
		  'Payment Received'
		elsif fund_transaction_detail.tx_code.to_s == FundTransactionDetail::TransactionCode::BITCOIN_SOLD.to_s
		  'Bitcoin Sold'
    elsif fund_transaction_detail.tx_code.to_s == FundTransactionDetail::TransactionCode::BITCOIN_PURCHASED.to_s
		  'Bitcoin Purchased'
    elsif fund_transaction_detail.tx_code.to_s == FundTransactionDetail::TransactionCode::COMMISSION.to_s
		  'Commission'
    else
			'Unknown'
		end
	end

	def btc_change fund_transaction_detail
		currency_change fund_transaction_detail, 'BTC'
	end

	def usd_change fund_transaction_detail
		currency_change fund_transaction_detail, 'USD'
	end
	
	def currency_change fund_transaction_detail, currency
		if fund_transaction_detail.tx_type.to_s == FundTransactionDetail::TransactionType::CREDIT.to_s
			"+ #{fund_transaction_detail.amount} #{currency}"
		else
			"- #{fund_transaction_detail.amount} #{currency}"
		end
	end

	def btc_notes fund_transaction_detail
	  unless fund_transaction_detail.btc_withdraw_request.nil?
		  "Sent to '#{fund_transaction_detail.btc_withdraw_request.destination_btc_address}' with message '#{fund_transaction_detail.btc_withdraw_request.message}'"
	  else
	    "#{fund_transaction_detail.message}"
	  end
	end
end
