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
    elsif fund_transaction_detail.tx_code.to_s == FundTransactionDetail::TransactionCode::WITHDRAWAL.to_s
		  'Withdrawal'
    elsif fund_transaction_detail.tx_code.to_s == FundTransactionDetail::TransactionCode::WITHDRAWAL_FEE.to_s
		  'Withdrawal Fee'
    elsif fund_transaction_detail.tx_code.to_s == FundTransactionDetail::TransactionCode::DEPOSIT_FEE.to_s
		  'Deposit Fee'
    elsif fund_transaction_detail.tx_code.to_s == FundTransactionDetail::TransactionCode::BITCOIN_FEE.to_s
		  'Bitcoin Fee'
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

  def btc_comments btc_detail
    if btc_detail["comment"]
      if btc_detail["comment"].starts_with?("bf-trade")
        'Traded'
      elsif btc_detail["comment"].starts_with?("bf-withdraw")
        'Withdrawn'
      else
        btc_detail["comment"]
      end
    else
      ''
    end
 #{btc_detail["comment"] && ?'Traded':(btc_detail["comment"].starts_with("bf-withdraw")?'Withdrawn':btc_detail["comment"])}
  end
end
