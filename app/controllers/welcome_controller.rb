class WelcomeController < ApplicationController

  def index
    @orders = Order.non_executed(current_user)
    @trades = Order.executed(current_user)
    @funds = Fund.where(:user_id => current_user.id)
  end

end
