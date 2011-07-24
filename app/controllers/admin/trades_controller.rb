module Admin
  class TradesController < ::Admin::BaseController
    def index
      @trades = Trade.includes(:bids, :asks).page(params[:page] || 1)
    end

    def show
    end
  end
end