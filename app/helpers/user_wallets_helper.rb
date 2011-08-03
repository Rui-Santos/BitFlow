module UserWalletsHelper
	def description desc
		if desc.to_s == BtcFundTransfer::Description::PaymentSent.to_s
			'Payment Sent'
		else
			'Unknown'
		end
	end

	def btc_change amount, tx_type
		if tx_type.to_s == BtcFundTransfer::TransactionType::CREDIT.to_s
			"+ #{amount} BTC"
		else
			"- #{amount} BTC"
		end
	end

	def btc_notes destination_btc_address, send_message
		"Sent to '#{destination_btc_address}' with message '#{send_message}'"
	end
end
