module Admin
  class FundWithdrawRequestsController < ::Admin::BaseController
    def index
      @fund_withdraw_requests = FundWithdrawRequest.order("created_at desc").all
      respond_to do |format|
        format.html
      end
    end
    def update
      @fund_withdraw_request = FundWithdrawRequest.find(params[:id])
      if params[:fund_withdraw_request][:decision] == "Accept"
        @fund_withdraw_request.update_attribute :status, FundWithdrawRequest::Status::SUCCESS
        total_amount = @fund_withdraw_request.amount + @fund_withdraw_request.fee
        @fund_withdraw_request.user.usd.unreserve!(total_amount)
        @fund_withdraw_request.user.usd.debit! :amount => @fund_withdraw_request.amount,
                                              :tx_code => FundTransactionDetail::TransactionCode::WITHDRAWAL,
                                              :currency => 'USD',
                                              :status => FundTransactionDetail::Status::COMMITTED,
                                              :message => @fund_withdraw_request.message,
                                              :user_id => @fund_withdraw_request.user.id,
                                              :fund_withdraw_request_id => @fund_withdraw_request.id
        @fund_withdraw_request.user.usd.debit! :amount => @fund_withdraw_request.fee,
                                              :tx_code => FundTransactionDetail::TransactionCode::WITHDRAWAL_FEE,
                                              :currency => 'USD',
                                              :status => FundTransactionDetail::Status::COMMITTED,
                                              :message => @fund_withdraw_request.message,
                                              :user_id => @fund_withdraw_request.user.id,
                                              :fund_withdraw_request_id => @fund_withdraw_request.id
        AdminUser.usd.credit! :amount => @fund_withdraw_request.fee,
                                              :tx_code => FundTransactionDetail::TransactionCode::WITHDRAWAL_FEE,
                                              :currency => 'USD',
                                              :status => FundTransactionDetail::Status::COMMITTED,
                                              :message => @fund_withdraw_request.message,
                                              :user_id => AdminUser.id,
                                              :fund_withdraw_request_id => @fund_withdraw_request.id
      else
        @fund_withdraw_request.update_attributes :status => FundWithdrawRequest::Status::DECLINED, :status_comment => params[:fund_withdraw_request][:status_comment]
        total_amount = @fund_withdraw_request.amount + @fund_withdraw_request.fee
        @fund_withdraw_request.user.usd.unreserve!(total_amount)
      end
      respond_to do |format|
        format.html { redirect_to(admin_fund_withdraw_requests_url) }
      end
    end
    def show
      @fund_withdraw_request = FundWithdrawRequest.find(params[:id])
    end
  end
end