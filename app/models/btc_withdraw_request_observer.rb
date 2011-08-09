class BtcWithdrawRequestObserver < ActiveRecord::Observer
  def before_create btc_withdraw_request
    btc_fund = btc_withdraw_request.user.btc
    if btc_fund.available >= btc_withdraw_request.amount
      btc_fund.reserve!(btc_fund.amount)
      return true
    else
      btc_withdraw_request.errors.add :base, 'Not enough Bitcoin fund available'
      return false
    end
  end
end