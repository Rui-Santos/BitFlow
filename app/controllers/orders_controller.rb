class OrdersController < ApplicationController

  def index
    @bids = Bid.user_transactions current_user
    @asks = Ask.user_transactions current_user
  end
end