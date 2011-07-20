class OrdersController < ApplicationController

  def index
    @asks = Ask.user_transactions current_user
    @bids = Bid.user_transactions current_user
  end
  
  def new
    @ask = Ask.new
    @bid = Bid.new
  end
end