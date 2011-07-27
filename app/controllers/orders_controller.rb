class OrdersController < ApplicationController

  def index
    # @asks = Ask.user_transactions(current_user).includes(:trade).page(params[:page] || 1)
    # @bids = Bid.user_transactions(current_user).includes(:trade).page(params[:page] || 1)
    @asks = Ask.user_transactions(current_user).page(params[:page] || 1)
    @bids = Bid.user_transactions(current_user).page(params[:page] || 1)
  end

  def new
    @ask = Ask.new
    @bid = Bid.new
  end
end