module Admin
  class TradesController < ::Admin::BaseController
    def index
      @trades = Trade.includes(:bid, :ask).page(params[:page] || 1)
    end

    def show
    end
  end
end