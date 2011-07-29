class BankaccountsController < ApplicationController
  # GET /bankaccounts
  # GET /bankaccounts.xml
  def index
    @bankaccounts = Bankaccount.where(:user_id => current_user.id, :status => Bankaccount::Status::ACTIVE)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /bankaccounts/new
  # GET /bankaccounts/new.xml
  def new
    @bankaccount = Bankaccount.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /bankaccounts
  # POST /bankaccounts.xml
  def create
    @bankaccount = Bankaccount.new(params[:bankaccount])
    @bankaccount.user = current_user
    @bankaccount.status = Bankaccount::Status::ACTIVE

    respond_to do |format|
      if @bankaccount.save
        format.html { redirect_to(bankaccounts_url, :notice => 'Bank account was successfully added.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # DELETE /bankaccounts/1
  # DELETE /bankaccounts/1.xml
  def destroy

    @bankaccount = Bankaccount.find(params[:id])
    fd = FundDeposit.where(:bankaccount_id => params[:id], :status => FundDeposit::Status::PENDING)
    if fd && fd.size > 0
      @bankaccount.errors.add(:base, 'Bank Name and Account Number cannot be removed as it is listed in a pending fund deposit request.')
    else
      authorised_block(@bankaccount) {@bankaccount.update_attribute :status, Bankaccount::Status::DELETED}
    end

    respond_to do |format|
      if @bankaccount.errors.size > 0
        format.html { redirect_to(bankaccounts_url, :notice => @bankaccount.errors.get(:base).first) }
      else
        format.html { redirect_to bankaccounts_url }
      end
    end

  end
end
