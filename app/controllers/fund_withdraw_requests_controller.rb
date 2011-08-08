class FundWithdrawRequestsController < ApplicationController
  def index
    @fund_withdraw_requests = FundWithdrawRequest.order("updated_at desc").where(:user_id => current_user.id)
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def new
    @fund_withdraw_request = FundWithdrawRequest.new
    @currencies = Currency.values
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    @fund_withdraw_request = FundWithdrawRequest.new(params[:fund_withdraw_request])
    @fund_withdraw_request.user_id = current_user.id
    @fund_withdraw_request.status = FundWithdrawRequest::Status::PENDING
    respond_to do |format|
      if @fund_withdraw_request.save
        format.html { redirect_to(fund_withdraw_requests_url, :notice => 'Fund withdrawal request was successfully created.') }
      else
        @currencies = Currency.values
        format.html { render :action => "new" }
      end
    end
  end
end
