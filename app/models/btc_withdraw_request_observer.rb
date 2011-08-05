class BtcWithdrawRequestObserver < ActiveRecord::Observer
  def after_commit(btc_withdraw_request)
    if btc_withdraw_request.status == BtcWithdrawRequest::Status::PENDING
      btc_withdraw_request.user.btc.debit :amount => btc_withdraw_request.amount,
                                        :currency => 'BTC',
                                        :tx_code => FundTransactionDetail::TransactionCode::PAYMENT_SENT,
                                        :status => FundTransactionDetail::Status::PENDING,
                                        :message => btc_withdraw_request.message,
                                        :user_id => btc_withdraw_request.user.id,
                                        :btc_withdraw_request_id => btc_withdraw_request.id
    end
  end
end