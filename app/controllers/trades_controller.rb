class TradesController < ApplicationController

  def index
    @trades = Trade.where(user: current_user).all(include: [:bids,:asks])
  end
  
  def show
    @trade = Trade.find(params[:id])
  end
end
