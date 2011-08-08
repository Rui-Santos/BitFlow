module Admin
  class FundsController < ::Admin::BaseController
    def index
      @funds = Fund.where(:user_id => current_user.id)
      @usd_fund_transaction_details = FundTransactionDetail.order("created_at desc").where(:user_id => current_user.id, :currency => 'USD')
    end
  end
end