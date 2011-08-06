class BtcWithdrawRequestsController < ApplicationController
  def new
    @btc_withdraw_request = BtcWithdrawRequest.new
    respond_to do |format|
      format.html # new.html.erb
    end
  end
  def create
    respond_to do |format|
      @btc_withdraw_request = BtcWithdrawRequest.new(params[:btc_withdraw_request])
      @btc_withdraw_request.user_id = current_user.id
      @btc_withdraw_request.status = BtcWithdrawRequest::Status::PENDING
      if current_user.btc.available >= @btc_withdraw_request.amount
        if @btc_withdraw_request.save
          format.html { redirect_to(user_wallets_path, :notice => 'Payment request was successfully created.') }
        else
          format.html { render :action => "new" }
        end
      else
        flash.now[:notice] = 'Insufficient BTC fund'
        format.html { render :action => "new" }
      end
    end
  end

end
