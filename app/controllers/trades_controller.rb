class TradesController < ApplicationController

  def index
    @trades = Order.executed(current_user)
  end

  def show
    @trade = Trade.find(params[:id])
  end

  def market_price
    @trade = Trade.last
    render :json => @trade
  end
end
