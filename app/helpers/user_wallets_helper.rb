module UserWalletsHelper
	def description fund_transaction_detail
		if fund_transaction_detail.tx_code.to_s == FundTransactionDetail::TransactionCode::PAYMENT_SENT.to_s
			'Payment Sent'
		else
			'Unknown'
		end
	end

	def btc_change fund_transaction_detail
		if fund_transaction_detail.tx_type.to_s == FundTransactionDetail::TransactionType::CREDIT
			"+ #{fund_transaction_detail.amount} BTC"
		else
			"- #{fund_transaction_detail.amount} BTC"
		end
	end

	def btc_notes fund_transaction_detail
		"Sent to '#{fund_transaction_detail.btc_withdraw_request.destination_btc_address}' with message '#{fund_transaction_detail.btc_withdraw_request.message}'"
	end
end
