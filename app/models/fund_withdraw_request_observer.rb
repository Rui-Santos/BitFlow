class FundWithdrawRequestObserver < ActiveRecord::Observer
  def before_create fund_withdraw_request
    usd_fund = fund_withdraw_request.user.usd
    if usd_fund.available >= fund_withdraw_request.amount
      usd_fund.reserve!(fund_withdraw_request.amount)
      return true
    else
      fund_withdraw_request.errors.add :base, 'Not enough USD fund available'
      return false
    end
  end
end
