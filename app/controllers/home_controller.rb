class HomeController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
    @bids = Bid.active.highest.all(:limit => 5)
    @asks = Ask.active.lowest.all(:limit => 5)
  end
end
