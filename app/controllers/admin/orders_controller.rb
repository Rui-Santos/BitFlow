module Admin
  class OrdersController < ::Admin::BaseController
    def index
      @asks = Ask.includes(:trade).page(params[:page] || 1)
      @bids = Bid.includes(:trade).page(params[:page] || 1)
    end

    def show
      
    end
  end
end