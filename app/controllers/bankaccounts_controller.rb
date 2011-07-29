class BankaccountsController < ApplicationController
  # GET /bankaccounts
  # GET /bankaccounts.xml
  def index
    @bankaccounts = Bankaccount.where(:user_id => current_user.id)

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
    authorised_block(@bankaccount) {@bankaccount.destroy}
    
    respond_to do |format|
      format.html { redirect_to(bankaccounts_url) }
    end
  end
end
