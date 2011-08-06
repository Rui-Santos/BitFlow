module Admin
  class FundDepositRequestsController < ::Admin::BaseController
    def index
      @search_criteria = SearchCriteria.new :email => nil, :account_number => nil
      @fund_deposit_requests = FundDepositRequest.order("updated_at").where(:status => FundDepositRequest::Status::PENDING)
      respond_to do |format|
        format.html
      end
    end
    def update
      @fund_deposit_request = FundDepositRequest.find(params[:id])
      @fund_deposit_request.update_attribute :status, FundDepositRequest::Status::COMPLETE
      respond_to do |format|
        format.html { redirect_to(admin_fund_deposit_requests_url) }
      end
    end
    def search
      @search_criteria = SearchCriteria.new(params[:search_criteria])
      email_criteria = @search_criteria.email.downcase
      acc_criteria = @search_criteria.account_number.downcase
      sql_deposit_code = "deposit_code like ?" unless email_criteria.blank?
      sql_acc = "lower(bankaccounts.number) like ?" unless acc_criteria.blank?
      if sql_deposit_code && sql_acc
        sql = "(#{sql_deposit_code} or #{sql_acc}) and fund_deposit_requests.status = ?"
        @fund_deposit_requests = FundDepositRequest.order("updated_at").joins(:bankaccount).where(sql, "%#{email_criteria}%", "%#{acc_criteria}%", FundDepositRequest::Status::PENDING)
      elsif sql_deposit_code
        sql = "#{sql_deposit_code} and fund_deposit_requests.status = ?"
        @fund_deposit_requests = FundDepositRequest.order("updated_at").joins(:bankaccount).where(sql, "%#{email_criteria}%", FundDepositRequest::Status::PENDING)
      elsif sql_acc
        sql = "#{sql_acc} and fund_deposit_requests.status = ?"
        @fund_deposit_requests = FundDepositRequest.order("updated_at").joins(:bankaccount).where(sql, "%#{acc_criteria}%", FundDepositRequest::Status::PENDING)
      else
        sql = "fund_deposit_requests.status = ?"
        @fund_deposit_requests = FundDepositRequest.order("updated_at").joins(:bankaccount).where(sql, FundDepositRequest::Status::PENDING)
      end
      respond_to do |format|
        format.html { render :index }
      end
    end
  end
end