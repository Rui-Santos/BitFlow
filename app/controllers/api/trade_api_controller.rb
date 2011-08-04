module Api
  class TradeApiController < ApplicationController
    def balance
      respond_to do |format|
        format.json { render :json => {:btc => @current_user.btc, :usd => @current_user.usd} }
      end
    end
  
    def orders
      respond_to do |format|
        format.json { render :json => Order.executed(current_user) }
      end
    end
  end
end