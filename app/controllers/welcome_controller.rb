class WelcomeController < ApplicationController

  def index
    @orders = Order.historic(current_user)
  end
  
  def wallet
  end
end
