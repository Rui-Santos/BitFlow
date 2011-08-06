class OrdersController < ApplicationController

  def index
    @asks = Ask.user_transactions(current_user).page(params[:page] || 1)
    @bids = Bid.user_transactions(current_user).page(params[:page] || 1)
    respond_to do |format|
      format.html {}
      format.json { render :json => {:asks => @asks, :bids => @bids}}
    end
    
  end

  def new
    @ask = Ask.new
    @bid = Bid.new
  end
end