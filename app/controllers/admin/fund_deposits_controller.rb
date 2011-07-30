module Admin
  class FundDepositsController < ::Admin::BaseController

    def index
      @search_criteria = SearchCriteria.new :email => nil, :account_number => nil
      @fund_deposits = FundDeposit.order("updated_at").where(:status => FundDeposit::Status::PENDING)

      respond_to do |format|
        format.html
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

    def search
      @search_criteria = SearchCriteria.new(params[:search_criteria])
      email_criteria = @search_criteria.email.downcase
      acc_criteria = @search_criteria.account_number.downcase
      sql_deposit_code = "deposit_code like ?" unless email_criteria.blank?
      sql_acc = "lower(bankaccounts.number) like ?" unless acc_criteria.blank?
      if sql_deposit_code && sql_acc
        sql = "(#{sql_deposit_code} or #{sql_acc}) and fund_deposits.status = ?"
        @fund_deposits = FundDeposit.order("updated_at").joins(:bankaccount).where(sql, "%#{email_criteria}%", "%#{acc_criteria}%", FundDeposit::Status::PENDING)
      elsif sql_deposit_code
        sql = "#{sql_deposit_code} and fund_deposits.status = ?"
        @fund_deposits = FundDeposit.order("updated_at").joins(:bankaccount).where(sql, "%#{email_criteria}%", FundDeposit::Status::PENDING)
      elsif sql_acc
        sql = "#{sql_acc} and fund_deposits.status = ?"
        @fund_deposits = FundDeposit.order("updated_at").joins(:bankaccount).where(sql, "%#{acc_criteria}%", FundDeposit::Status::PENDING)
      else
        sql = "fund_deposits.status = ?"
        @fund_deposits = FundDeposit.order("updated_at").joins(:bankaccount).where(sql, FundDeposit::Status::PENDING)
      end

      respond_to do |format|
        format.html { render :index }
      end
    end

  end
end