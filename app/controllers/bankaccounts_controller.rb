class BankaccountsController < ApplicationController
  # GET /bankaccounts
  # GET /bankaccounts.xml
  def index
    @bankaccounts = Bankaccount.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /bankaccounts/1
  # GET /bankaccounts/1.xml
  def show
    @bankaccount = Bankaccount.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
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

  # GET /bankaccounts/1/edit
  def edit
    @bankaccount = Bankaccount.find(params[:id])
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

  # PUT /bankaccounts/1
  # PUT /bankaccounts/1.xml
  def update
    @bankaccount = Bankaccount.find(params[:id])

    respond_to do |format|
      if @bankaccount.update_attributes(params[:bankaccount])
        format.html { redirect_to(bankaccounts_url, :notice => 'Bank account was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /bankaccounts/1
  # DELETE /bankaccounts/1.xml
  def destroy
    @bankaccount = Bankaccount.find(params[:id])
    @bankaccount.destroy

    respond_to do |format|
      format.html { redirect_to(bankaccounts_url) }
      format.xml  { head :ok }
    end
  end
end
