class UsersController < ApplicationController
  def show
    
  end
  
  def update
    current_user.update_attributes(params[:user])
    render :show
  end
end
