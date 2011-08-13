class UserWalletsController < ApplicationController
  # GET /user_wallets
  def index
    respond_to do |format|
      @user_wallet = UserWallet.where(:user_id => current_user.id, :status => UserWallet::Status::ACTIVE).first
      if @user_wallet
        begin
          bal = BitcoinProxy.balance(@user_wallet.name, 5)
          @user_wallet.update_attribute :balance, bal  unless bal == @user_wallet.balance
          current_user.sync_with_bitcoind
        rescue => e
          puts e.backtrace.join "\n"
          flash.now[:notice] = "Error in Wallet Balance fetch: #{e.inspect}"
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
      @fund_transaction_details = FundTransactionDetail.order("updated_at desc").where(:user_id => current_user.id, :currency => 'BTC')
      format.html { render(:action => 'index') }
    end
  end
end
