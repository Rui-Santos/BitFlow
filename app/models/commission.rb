class Commission 
  def self.amount(user)
  	if user.undiscounted_commission?
  		commission = Setting.admin.data[:commission_fee]
  		commission
  	else
  		settings = Setting.admin
  		commission = settings.data[:commission_fee]
  		discount = settings.data.[:referral_discount_percentage]
  		commission * ((100 - discount)/100)
  	end
  end
end