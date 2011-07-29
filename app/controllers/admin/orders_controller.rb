module Admin
  class OrdersController < ::Admin::BaseController
    def index
      @asks = Ask.page(params[:page] || 1)
      @bids = Bid.page(params[:page] || 1)
    end

    def show

    end
  end
end