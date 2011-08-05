class FundDepositRequestObserver < ActiveRecord::Observer
  def after_commit(fund_deposit_request)
    if fund_deposit_request.status == FundDepositRequest::Status::COMPLETE
      fund_deposit_request.user.usd.credit :amount => fund_deposit_request.net_amount,
                                        :currency => 'USD',
                                        :tx_code => FundTransactionDetail::TransactionCode::PAYMENT_RECEIVED,
                                        :status => FundTransactionDetail::Status::COMMITTED,
                                        :user_id => fund_deposit_request.user.id,
                                        :fund_deposit_request_id => fund_deposit_request.id
    end
  end
end
