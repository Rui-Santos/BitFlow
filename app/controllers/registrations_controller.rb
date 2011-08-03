class RegistrationsController < Devise::RegistrationsController

  def create
    if verify_recaptcha
      referrer_code = params[:user][:referrer_code]
      if referrer_code.blank?
        super
      else
        referrer = User.where(:referral_code => referrer_code).first
        if referrer.nil?
          build_resource
          clean_up_passwords(resource)
          flash.now[:alert] = "Referral Code doesn't exist. Please enter a valid one or clear it before submitting again."
          render_with_scope :new
        else
          referrer_usd_fund = referrer.funds.detect {|fund| fund.fund_type == 'USD'}
          already_referrered = User.where(:referrer_fund_id => referrer_usd_fund.id).first
          if already_referrered.nil?
            super
          else
            build_resource
            clean_up_passwords(resource)
            flash.now[:alert] = "Referral Code has already been used. Please enter a valid one or clear it before submitting again."
            render_with_scope :new
          end
        end
      end
    else
      build_resource
      clean_up_passwords(resource)
      flash.now[:alert] = "There was an error with the recaptcha code below. Please re-enter the code and click submit."
      render_with_scope :new
    end
  end

end