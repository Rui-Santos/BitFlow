class TradesController < ApplicationController

  def index
    @trades = Trade.where(user: current_user).all(include: [:bids,:asks])
  end
  
  def show
    @trade = Trade.find(params[:id])
  end
  
  def market_price
    @trade = Trade.last
    render :json => @trade
  end
end
