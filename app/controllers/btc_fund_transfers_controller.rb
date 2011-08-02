class BtcFundTransfersController < ApplicationController

  # GET /btc_fund_transfers/new
  # GET /btc_fund_transfers/new.xml
  def new
    @btc_fund_transfer = BtcFundTransfer.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /btc_fund_transfers
  # POST /btc_fund_transfers.xml
  def create
    @btc_fund_transfer = BtcFundTransfer.new(params[:btc_fund_transfer])
    @btc_fund_transfer.user_id = current_user.id
    @btc_fund_transfer.fund_id = Fund.find_btc(current_user.id)
    @btc_fund_transfer.status = BtcFundTransfer::Status::PENDING
    @btc_fund_transfer.transaction_type = BtcFundTransfer::TransactionType::DEBIT
    @btc_fund_transfer.description = BtcFundTransfer::Description::PaymentSent

    respond_to do |format|
      if @btc_fund_transfer.save
        format.html { redirect_to(user_wallets_path, :notice => 'Payment request was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

end
