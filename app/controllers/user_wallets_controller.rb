class UserWalletsController < ApplicationController
  # GET /user_wallets
  def index
    respond_to do |format|
      @user_wallet = UserWallet.where(:user_id => current_user.id, :status => UserWallet::Status::ACTIVE).first
      if @user_wallet
        begin
          bal = BitcoinProxy.balance(@user_wallet.name)
          @user_wallet.update_attribute :balance, bal  unless bal == @user_wallet.balance
        rescue => e
          flash.now[:notice] = 'Error in Wallet Balance fetch'
        end
      else
        begin
          address = BitcoinProxy.new_address(current_user.email)
          @user_wallet = UserWallet.new :name => current_user.email, 
                                        :status => UserWallet::Status::ACTIVE, 
                                        :address => address, 
                                        :balance => 0.0, 
                                        :user_id => current_user.id
          if @user_wallet.save
            flash.now[:notice] = 'Wallet was successfully created'
          else
            flash.now[:notice] = 'Error in Wallet creation'
          end
        rescue => e
          flash.now[:notice] = 'Error in Bitcoin Address creation'
        end
      end
      @btc_fund_transfers = BtcFundTransfer.order("updated_at desc").where(:user_id => current_user.id)
      format.html { render(:action => 'index') }
    end
  end
end
