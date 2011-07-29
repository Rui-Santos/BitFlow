class FundDepositsController < ApplicationController
  # GET /fund_deposits
  # GET /fund_deposits.xml
  def index
    @fund_deposits = FundDeposit.where(:user_id => current_user.id)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /fund_deposits/new
  # GET /fund_deposits/new.xml
  def new
    @fund_deposit = FundDeposit.new
    @currencies = Currency.values
    @bank_accounts = Bankaccount.where(:user_id => current_user.id, :status => Bankaccount::Status::ACTIVE)

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /fund_deposits
  # POST /fund_deposits.xml
  def create
    @fund_deposit = FundDeposit.new(params[:fund_deposit])
    @fund_deposit.user_id = current_user.id
    @fund_deposit.status = FundDeposit::Status::PENDING

    respond_to do |format|
      if @fund_deposit.save
        format.html { redirect_to(fund_deposits_url, :notice => 'Fund deposit was successfully created.') }
      else
        @currencies = Currency.values
        @bank_accounts = Bankaccount.where(:user_id => current_user.id, :status => Bankaccount::Status::ACTIVE)
        format.html { render :action => "new" }
      end
    end
  end

  # DELETE /fund_deposits/1
  # DELETE /fund_deposits/1.xml
  def destroy
    @fund_deposit = FundDeposit.find(params[:id])
    authorised_block(@fund_deposit) {@fund_deposit.update_attribute :status, FundDeposit::Status::CANCELLED}

    respond_to do |format|
      format.html { redirect_to(fund_deposits_url) }
    end
  end
end