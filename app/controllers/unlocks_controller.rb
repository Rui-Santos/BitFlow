class UnlocksController < Devise::UnlocksController

  def create
    if verify_recaptcha
      super
    else
      Rails.logger.debug "InValid Recapcha"
      flash.now[:alert] = "There was an error with the recaptcha code below. Please re-enter the code and click submit."
      render_with_scope :new
    end
  end
end