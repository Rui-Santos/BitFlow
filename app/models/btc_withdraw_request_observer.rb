class BtcWithdrawRequestObserver < ActiveRecord::Observer
  def after_commit(btc_withdraw_request)
    if btc_withdraw_request.status == BtcWithdrawRequest::Status::PENDING
      btc_withdraw_request.user.btc.debit! :amount => btc_withdraw_request.amount,
                                        :currency => 'BTC',
                                        :tx_code => FundTransactionDetail::TransactionCode::PAYMENT_SENT,
                                        :status => FundTransactionDetail::Status::PENDING,
                                        :message => btc_withdraw_request.message,
                                        :user_id => btc_withdraw_request.user.id,
                                        :btc_withdraw_request_id => btc_withdraw_request.id
      # tx_id = BitcoinProxy.send_from(btc_withdraw_request.user.user_wallet.name, 
      #                       btc_withdraw_request.destination_btc_address,
      #                       btc_withdraw_request.amount,
      #                       btc_withdraw_request.message,
      #                       btc_withdraw_request.message)
      # btc_withdraw_request.update_attribute(:btc_tx_id, tx_id)
    end
  end
end