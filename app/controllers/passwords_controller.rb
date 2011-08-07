class PasswordsController < Devise::PasswordsController
  def create
    if verify_recaptcha
      super
    else
      flash.now[:alert] = "There was an error with the recaptcha code below. Please re-enter the code and click submit."
      render_with_scope :new
    end
  end
end