class HomeController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
    @bids = Bid.active.highest.all(:limit => 5)
    @asks = Ask.active.lowest.all(:limit => 5)
  end
  def about_us; end
  
  def faq; end
  def contact_us; end

  def terms_of_use; end
  def privacy_policy; end
  def latest_updates; end
  def trading_api; end
  def affiliate_program; end
end
