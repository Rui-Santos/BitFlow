class WelcomeController < ApplicationController

  def index
    @orders = Order.non_executed(current_user)
    @trades = Order.executed(current_user)
  end
  
  def wallet
  end
end
