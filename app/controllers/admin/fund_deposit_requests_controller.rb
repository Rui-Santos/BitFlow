module Admin
  class FundDepositRequestsController < ::Admin::BaseController
    def index
      @search_criteria = SearchCriteria.new :email => nil, :account_number => nil
      @fund_deposit_requests = FundDepositRequest.order("updated_at").where(:status => FundDepositRequest::Status::PENDING)
      respond_to do |format|
        format.html
      end
    end
    def show
      @fund_deposit_request = FundDepositRequest.find(params[:id])
    end
    def update
      @fund_deposit_request = FundDepositRequest.find(params[:id])
      fee = params[:fund_deposit_request][:fee]
      amount_received = params[:fund_deposit_request][:amount_received].to_f
      @fund_deposit_request.update_attributes :status => FundDepositRequest::Status::COMPLETE, 
                                              :amount_received => amount_received,
                                              :fee => fee
      @fund_deposit_request.user.usd.credit! :amount => amount_received,
                                            :currency => 'USD',
                                            :tx_code => FundTransactionDetail::TransactionCode::PAYMENT_RECEIVED,
                                            :status => FundTransactionDetail::Status::COMMITTED,
                                            :user_id => @fund_deposit_request.user.id,
                                            :fund_deposit_request_id => @fund_deposit_request.id
      unless fee.blank?
        AdminUser.usd.credit! :amount => fee.to_f,
                              :currency => 'USD',
                              :tx_code => FundTransactionDetail::TransactionCode::DEPOSIT_FEE,
                              :status => FundTransactionDetail::Status::COMMITTED,
                              :user_id => AdminUser.id,
                              :fund_deposit_request_id => @fund_deposit_request.id
        @fund_deposit_request.user.usd.debit! :amount => fee.to_f,
                              :currency => 'USD',
                              :tx_code => FundTransactionDetail::TransactionCode::DEPOSIT_FEE,
                              :status => FundTransactionDetail::Status::COMMITTED,
                              :user_id => @fund_deposit_request.user.id,
                              :fund_deposit_request_id => @fund_deposit_request.id
      end
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