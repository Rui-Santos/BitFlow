class FundDepositRequestsController < ApplicationController
  def index
    @fund_deposit_requests = FundDepositRequest.order("updated_at desc").where(:user_id => current_user.id)
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  def new
    @fund_deposit_request = FundDepositRequest.new
    @currencies = Currency.values
    @bank_accounts = Bankaccount.where(:user_id => current_user.id, :status => Bankaccount::Status::ACTIVE)
    respond_to do |format|
      format.html # new.html.erb
    end
  end
  def create
    @fund_deposit_request = FundDepositRequest.new(params[:fund_deposit_request])
    @fund_deposit_request.user_id = current_user.id
    @fund_deposit_request.status = FundDepositRequest::Status::PENDING
    @fund_deposit_request.net_amount = @fund_deposit_request.amount
    @fund_deposit_request.deposit_code = current_user.email.downcase
    respond_to do |format|
      if @fund_deposit_request.save
        format.html { redirect_to(fund_deposit_requests_url, :notice => 'Fund deposit Request was successfully created.') }
      else
        @currencies = Currency.values
        @bank_accounts = Bankaccount.where(:user_id => current_user.id, :status => Bankaccount::Status::ACTIVE)
        format.html { render :action => "new" }
      end
    end
  end
  def destroy
    @fund_deposit_request = FundDepositRequest.find(params[:id])
    authorised_block(@fund_deposit_request) {@fund_deposit_request.update_attribute :status, FundDepositRequest::Status::CANCELLED}
    respond_to do |format|
      format.html { redirect_to(fund_deposit_requests_url) }
    end
  end
end
