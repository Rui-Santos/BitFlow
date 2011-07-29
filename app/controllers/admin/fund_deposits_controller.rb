module Admin
  class FundDepositsController < ::Admin::BaseController
    def index
      @fund_deposits = FundDeposit.order("updated_at").where(:status => FundDeposit::Status::PENDING)

      respond_to do |format|
        format.html # index.html.erb
      end
    end

    def update
      @fund_deposit = FundDeposit.find(params[:id])
      @fund_deposit.update_attribute :status, FundDeposit::Status::COMPLETE
      usd_fund = Fund.find_usd(@fund_deposit.user_id)
      usd_fund.update_attributes(:amount => (usd_fund.amount + @fund_deposit.net_amount),
                                  :available => (usd_fund.available + @fund_deposit.net_amount))

      respond_to do |format|
        format.html { redirect_to(admin_fund_deposits_url) }
      end
    end
  end
end