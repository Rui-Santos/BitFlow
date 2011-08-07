class FundWithdrawRequestObserver < ActiveRecord::Observer
  def before_create fund_withdraw_request
    total_amount = fund_withdraw_request.amount + fund_withdraw_request.fee
    usd_fund = fund_withdraw_request.user.usd
    if usd_fund.available >= total_amount
      usd_fund.reserve!(total_amount)
      return true
    else
      fund_withdraw_request.errors.add :base, 'Not enough USD fund available'
      return false
    end
  end
end
