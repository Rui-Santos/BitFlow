class OrdersController < ApplicationController

  def index
    @orders = Order.historic(current_user, 50)
  end
end