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
      decision = params[:fund_withdraw_request][:decision]
      if decision == "Accept"
        fee = params[:fund_withdraw_request][:fee].blank? ? 0.0 : params[:fund_withdraw_request][:fee].to_f
        if fee > @fund_withdraw_request.user.usd.available
          @fund_withdraw_request.errors.add :base, 'Fee amount cannot be more than Available Fund amount'
        else
          @fund_withdraw_request.update_attributes :status => FundWithdrawRequest::Status::SUCCESS, 
                                                :fee => fee
          @fund_withdraw_request.user.usd.unreserve!(@fund_withdraw_request.amount)
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
        end
      else
        status_comment = params[:fund_withdraw_request][:status_comment]
        @fund_withdraw_request.update_attributes :status => FundWithdrawRequest::Status::DECLINED, 
                                                :status_comment => status_comment
        @fund_withdraw_request.user.usd.unreserve!(@fund_withdraw_request.amount)
      end
      respond_to do |format|
        if @fund_withdraw_request.errors.empty?
          format.html { redirect_to(admin_fund_withdraw_requests_url) }
        else
          flash[:notice] = @fund_withdraw_request.errors[:base].join(", ")
          format.html {redirect_to :action => :show}
        end
      end
    end
    def show
      @fund_withdraw_request = FundWithdrawRequest.find(params[:id])
    end
  end
end