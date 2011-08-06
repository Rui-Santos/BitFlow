class UsdFundTransactionDetailsController < ApplicationController

  def index
    @usd_fund_transaction_details = FundTransactionDetail.order("created_at desc").where(:user_id => current_user.id, :currency => 'USD')
  end

end